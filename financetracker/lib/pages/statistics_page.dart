import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';
import '../services/api_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<List<Transaction>> _transactionsFuture;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int? _touchedIndex;

  static const Map<String, Color> categoryColors = {
    'Wohnen': Color(0xFF26A69A),
    'Essen': Color(0xFFEF5350),
    'Freizeit': Color(0xFFAB47BC),
    'Transport': Color(0xFF42A5F5),
    'Einkommen': Color(0xFF66BB6A),
    'Sonstiges': Color(0xFFFFA726),
  };

  @override
  void initState() {
    super.initState();
    _transactionsFuture = ApiService.getTransactions();
  }

  void _refresh() {
    setState(() {
      _transactionsFuture = ApiService.getTransactions();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
      _touchedIndex = null;
    });
  }

  List<Transaction> _filterByMonth(List<Transaction> all) {
    return all
        .where(
          (t) =>
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .toList();
  }

  Map<String, double> _expensesByCategory(List<Transaction> transactions) {
    final map = <String, double>{};
    for (final t in transactions.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Ausgaben der letzten 6 Monate (inkl. aktuellem)
  Map<DateTime, double> _monthlyExpenses(List<Transaction> all) {
    final map = <DateTime, double>{};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(_selectedMonth.year, _selectedMonth.month - i);
      map[month] = 0;
    }
    for (final t in all.where((t) => t.isExpense)) {
      final key = DateTime(t.date.year, t.date.month);
      if (map.containsKey(key)) {
        map[key] = map[key]! + t.amount;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthFormat = DateFormat('MMMM yyyy', 'de_DE');
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return SafeArea(
      child: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Backend nicht erreichbar',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final allTransactions = snapshot.data!;
          final monthTransactions = _filterByMonth(allTransactions);
          final expenseMap = _expensesByCategory(monthTransactions);
          final totalExpenses = expenseMap.values.fold<double>(
            0,
            (a, b) => a + b,
          );
          final totalIncome = monthTransactions
              .where((t) => t.isIncome)
              .fold<double>(0, (a, b) => a + b.amount);
          final monthlyExp = _monthlyExpenses(allTransactions);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header mit Monatsnavigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          monthFormat.format(_selectedMonth),
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // PDF Export Button
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _exportPdf(
                      context,
                      monthFormat.format(_selectedMonth),
                      expenseMap,
                      totalExpenses,
                      totalIncome,
                      monthlyExp,
                      currencyFormat,
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF Export'),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollbarer Inhalt
                Expanded(
                  child: ListView(
                    children: [
                      // Einnahmen / Ausgaben Karte
                      _buildSummaryCard(
                        theme,
                        currencyFormat,
                        totalIncome,
                        totalExpenses,
                      ),
                      const SizedBox(height: 20),

                      // Kreisdiagramm
                      Text(
                        'Ausgaben nach Kategorie',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (expenseMap.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('Keine Ausgaben in diesem Monat'),
                          ),
                        )
                      else ...[
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _buildPieSections(
                                expenseMap,
                                totalExpenses,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legende
                        ...expenseMap.entries.map((e) {
                          final pct = (e.value / totalExpenses * 100)
                              .toStringAsFixed(1);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: categoryColors[e.key] ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e.key)),
                                Text(
                                  '${currencyFormat.format(e.value)}  ($pct %)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 28),

                      // Monatstrend Balkendiagramm
                      Text(
                        'Monatstrend (Ausgaben)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(
                          theme,
                          monthlyExp,
                          currencyFormat,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    NumberFormat fmt,
    double income,
    double expenses,
  ) {
    final diff = income - expenses;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _summaryColumn(
                'Einnahmen',
                fmt.format(income),
                Colors.green,
                Icons.arrow_downward,
              ),
            ),
            Container(width: 1, height: 48, color: theme.dividerColor),
            Expanded(
              child: _summaryColumn(
                'Ausgaben',
                fmt.format(expenses),
                Colors.red,
                Icons.arrow_upward,
              ),
            ),
            Container(width: 1, height: 48, color: theme.dividerColor),
            Expanded(
              child: _summaryColumn(
                'Differenz',
                fmt.format(diff),
                diff >= 0 ? Colors.green : Colors.red,
                diff >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryColumn(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> expenseMap,
    double total,
  ) {
    final entries = expenseMap.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final entry = entries[i];
      final pct = entry.value / total * 100;
      return PieChartSectionData(
        color: categoryColors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: isTouched ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildBarChart(
    ThemeData theme,
    Map<DateTime, double> monthlyExp,
    NumberFormat fmt,
  ) {
    final entries = monthlyExp.entries.toList();
    final maxY = entries
        .map((e) => e.value)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final shortMonth = DateFormat('MMM', 'de_DE');

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gIndex, rod, rIndex) {
              return BarTooltipItem(
                fmt.format(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    shortMonth.format(entries[idx].key),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (i) {
          final isCurrentMonth =
              entries[i].key.year == _selectedMonth.year &&
              entries[i].key.month == _selectedMonth.month;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value,
                color: isCurrentMonth
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.35),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

// PDF Export
  Future<void> _exportPdf(
    BuildContext context,
    String monthLabel,
    Map<String, double> expenseMap,
    double totalExpenses,
    double totalIncome,
    Map<DateTime, double> monthlyExp,
    NumberFormat currencyFormat,
  ) async {
    final pdf = pw.Document();
    final shortMonth = DateFormat('MMM yyyy', 'de_DE');
    final pdfCurrency = NumberFormat.currency(locale: 'de_DE', symbol: 'EUR');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Statistik ($monthLabel)',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Zusammenfassung
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfSummaryBox(
                    'Einnahmen',
                    pdfCurrency.format(totalIncome),
                    PdfColors.green,
                  ),
                  _pdfSummaryBox(
                    'Ausgaben',
                    pdfCurrency.format(totalExpenses),
                    PdfColors.red,
                  ),
                  _pdfSummaryBox(
                    'Differenz',
                    pdfCurrency.format(totalIncome - totalExpenses),
                    totalIncome >= totalExpenses
                        ? PdfColors.green
                        : PdfColors.red,
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Kategorie-Tabelle
              pw.Text(
                'Ausgaben nach Kategorie',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (expenseMap.isEmpty)
                pw.Text('Keine Ausgaben in diesem Monat')
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _pdfCell('Kategorie', bold: true),
                        _pdfCell('Betrag', bold: true),
                        _pdfCell('Anteil', bold: true),
                      ],
                    ),
                    ...expenseMap.entries.map((e) {
                      final pct = totalExpenses > 0
                          ? '${(e.value / totalExpenses * 100).toStringAsFixed(1)}%'
                          : '–';
                      return pw.TableRow(
                        children: [
                          _pdfCell(e.key),
                          _pdfCell(pdfCurrency.format(e.value)),
                          _pdfCell(pct),
                        ],
                      );
                    }),
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _pdfCell('Gesamt', bold: true),
                        _pdfCell(pdfCurrency.format(totalExpenses), bold: true),
                        _pdfCell('100%', bold: true),
                      ],
                    ),
                  ],
                ),
              pw.SizedBox(height: 24),

              // Monatstrend
              pw.Text(
                'Monatstrend (Ausgaben)',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _pdfCell('Monat', bold: true),
                      _pdfCell('Ausgaben', bold: true),
                    ],
                  ),
                  ...monthlyExp.entries.map(
                    (e) => pw.TableRow(
                      children: [
                        _pdfCell(shortMonth.format(e.key)),
                        _pdfCell(pdfCurrency.format(e.value)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Erstellt am ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    try {
      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Statistik_$monthLabel.pdf');
      await file.writeAsBytes(await pdf.save());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF gespeichert: ${file.path}'),
            action: SnackBarAction(
              label: 'Öffnen',
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF-Export fehlgeschlagen: $e')),
        );
      }
    }
  }

  pw.Widget _pdfSummaryBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
