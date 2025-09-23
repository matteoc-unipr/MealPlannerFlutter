import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart' as data_kit;
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.initialKcalTarget = 2000,
    this.initialMacroTargets = const Nutrients(),
    this.initialAllergies = const <String>[],
    this.initialShoppingDay = Weekday.monday,
    this.initialHealthIntegrationEnabled = false,
    Future<Map<String, dynamic>> Function()? exportJson,
    Future<void> Function()? eraseAll,
    String? exportPath,
  })  : exportJson = exportJson ?? data_kit.exportJson,
        eraseAll = eraseAll ?? data_kit.eraseAll,
        exportPath = exportPath ?? defaultExportPath;

  static const String defaultExportPath = 'app/documents/export.json';

  final int initialKcalTarget;
  final Nutrients initialMacroTargets;
  final List<String> initialAllergies;
  final Weekday initialShoppingDay;
  final bool initialHealthIntegrationEnabled;
  final Future<Map<String, dynamic>> Function() exportJson;
  final Future<void> Function() eraseAll;
  final String exportPath;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _calorieController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbohydrateController;
  late final TextEditingController _fatController;
  late final TextEditingController _allergiesController;
  late Weekday _selectedDay;
  late bool _healthIntegrationEnabled;
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController(
      text: widget.initialKcalTarget > 0
          ? widget.initialKcalTarget.toString()
          : '',
    );
    _proteinController =
        TextEditingController(text: _formatNumber(widget.initialMacroTargets.protein));
    _carbohydrateController = TextEditingController(
      text: _formatNumber(widget.initialMacroTargets.carbohydrates),
    );
    _fatController =
        TextEditingController(text: _formatNumber(widget.initialMacroTargets.fat));
    _allergiesController =
        TextEditingController(text: widget.initialAllergies.join(', '));
    _selectedDay = widget.initialShoppingDay;
    _healthIntegrationEnabled = widget.initialHealthIntegrationEnabled;
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbohydrateController.dispose();
    _fatController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target calorico',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settings_kcal_field'),
                controller: _calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calorie giornaliere (kcal)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Obiettivi macro',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Imposta gli obiettivi giornalieri per i principali macronutrienti.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_protein_field'),
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Proteine (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_carbs_field'),
                controller: _carbohydrateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carboidrati (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_fat_field'),
                controller: _fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Grassi (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Allergie',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settings_allergies_field'),
                controller: _allergiesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Inserisci le allergie separate da virgola',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<Weekday>(
                key: const Key('settings_shopping_day_field'),
                value: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Giorno della spesa',
                  border: OutlineInputBorder(),
                ),
                items: Weekday.values
                    .map(
                      (weekday) => DropdownMenuItem<Weekday>(
                        value: weekday,
                        child: Text(_weekdayLabel(weekday)),
                      ),
                    )
                    .toList(),
                onChanged: (weekday) {
                  if (weekday == null) {
                    return;
                  }
                  setState(() {
                    _selectedDay = weekday;
                  });
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                key: const Key('settings_health_toggle'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Sincronizza con Health'),
                subtitle: const Text(
                  'Abilita l\'integrazione con i servizi di salute del dispositivo.',
                ),
                value: _healthIntegrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _healthIntegrationEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('settings_export_button'),
                  onPressed: _isExporting ? null : _onExportPressed,
                  child: _isExporting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Export'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('settings_delete_button'),
                  onPressed: _isDeleting ? null : _onDeletePressed,
                  child: _isDeleting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        )
                      : const Text('Delete Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _weekdayLabel(Weekday day) {
    final name = day.name;
    if (name.isEmpty) {
      return '';
    }
    return name[0].toUpperCase() + name.substring(1);
  }

  Future<void> _onExportPressed() async {
    if (_isExporting) {
      return;
    }
    setState(() {
      _isExporting = true;
    });

    try {
      final snapshot = await widget.exportJson();
      final file = File(widget.exportPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(snapshot), flush: true);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esportazione completata.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore durante l'esportazione: $error"),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _onDeletePressed() async {
    if (_isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: const Text(
            'Sei sicuro di voler eliminare tutti i dati salvati? Questa azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              key: const Key('settings_cancel_delete_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              key: const Key('settings_confirm_delete_button'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.eraseAll();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutti i dati sono stati eliminati.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore durante l'eliminazione: $error"),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
