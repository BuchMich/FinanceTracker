import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../services/api_service.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late Future<List<SavingsGoal>> _goalsFuture;
  final _currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  @override
  void initState() {
    super.initState();
    _goalsFuture = ApiService.getSavingsGoals();
  }

  void _refresh() {
    setState(() {
      _goalsFuture = ApiService.getSavingsGoals();
    });
  }

  // -------------------- Dialoge --------------------

  Future<void> _showAddGoalDialog() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Sparziel'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Bitte Titel eingeben'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Zielbetrag (€)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Bitte Betrag eingeben';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Ungültiger Betrag';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final goal = SavingsGoal(
        title: titleController.text.trim(),
        targetAmount: double.parse(amountController.text.replaceAll(',', '.')),
      );
      await ApiService.addSavingsGoal(goal);
      _refresh();
    }
  }

  Future<void> _showDepositDialog(SavingsGoal goal) async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Einzahlung – ${goal.title}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Betrag (€)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Bitte Betrag eingeben';
              final n = double.tryParse(v.replaceAll(',', '.'));
              if (n == null || n <= 0) return 'Ungültiger Betrag';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Einzahlen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deposit = double.parse(amountController.text.replaceAll(',', '.'));
      final updated = SavingsGoal(
        id: goal.id,
        title: goal.title,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount + deposit,
      );
      await ApiService.updateSavingsGoal(updated);
      _refresh();
    }
  }

  Future<void> _confirmDelete(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sparziel löschen?'),
        content: Text('„${goal.title}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteSavingsGoal(goal.id!);
      _refresh();
    }
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meine Sparziele',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Liste
              Expanded(
                child: FutureBuilder<List<SavingsGoal>>(
                  future: _goalsFuture,
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
                            const SizedBox(height: 4),
                            Text(
                              '${snapshot.error}',
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
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

                    final goals = snapshot.data!;

                    if (goals.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Noch keine Sparziele',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tippe auf + um ein neues Sparziel anzulegen.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildGoalCard(goals[index], theme),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDepositDialog(goal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titel + Löschen-Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      onPressed: () => _confirmDelete(goal),
                      icon: Icon(Icons.close, color: theme.colorScheme.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Ziel: ${_currencyFormat.format(goal.targetAmount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),

              // Fortschrittsbalken
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 22,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${goal.progressPercent}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: goal.progress > 0.45
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_currencyFormat.format(goal.currentAmount)} erreicht',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
