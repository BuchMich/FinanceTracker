import 'package:flutter/material.dart';
import '../main.dart';
import '../services/theme_service.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _themeExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildDataSection(),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Erscheinungsbild',
        border: OutlineInputBorder(),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _themeExpanded = !_themeExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Theme: ${themeService.themeLabel}'),
                  Icon(_themeExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_themeExpanded) ...[
            _buildThemeOption(AppThemeMode.light, 'Light'),
            _buildThemeOption(AppThemeMode.dark, 'Dark'),
            _buildThemeOption(AppThemeMode.system, 'System'),
            _buildThemeOption(AppThemeMode.greenMode, 'Green-Mode'),
            _buildThemeOption(AppThemeMode.highContrast, 'High-Contrast'),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeOption(AppThemeMode mode, String label) {
    return RadioListTile<AppThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: themeService.themeMode,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (value) {
        if (value != null) {
          setState(() => themeService.setThemeMode(value));
        }
      },
    );
  }

  Widget _buildDataSection() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Datenverwaltung',
        border: OutlineInputBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _confirmResetData,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'ALLE DATEN ZURÜCKSETZEN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daten zurücksetzen'),
        content: const Text(
          'Möchtest du wirklich alle Transaktionen und Sparziele unwiderruflich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      await ApiService.deleteAllTransactions();
      await ApiService.deleteAllSavingsGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alle Daten wurden zurückgesetzt.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Zurücksetzen der Daten.')),
        );
      }
    }
  }
}
