import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  double get _saldo => demoTransactions.fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yy');
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FinanceFlow',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dashboard',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),

            // Saldo-Karte
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gesamtsaldo:', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(_saldo),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Letzte Umsätze
            Text(
              'Letzte Umsätze',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: demoTransactions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = demoTransactions[index];
                  final isPositive = t.amount >= 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.title),
                    subtitle: Text(dateFormat.format(t.date)),
                    trailing: Text(
                      '${isPositive ? '+' : ''}${currencyFormat.format(t.amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
