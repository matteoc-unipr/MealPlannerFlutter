import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart' as data_kit;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.settingsCalorieTargetSectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settings_kcal_field'),
                controller: _calorieController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.settingsDailyCaloriesLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  l10n.settingsMacroGoalsSectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsMacroGoalsDescription,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_protein_field'),
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.settingsProteinLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_carbs_field'),
                controller: _carbohydrateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.settingsCarbsLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('settings_fat_field'),
                controller: _fatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.settingsFatLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  l10n.settingsAllergiesSectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settings_allergies_field'),
                controller: _allergiesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.settingsAllergiesHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<Weekday>(
                key: const Key('settings_shopping_day_field'),
                value: _selectedDay,
                decoration: InputDecoration(
                  labelText: l10n.settingsShoppingDayLabel,
                  border: const OutlineInputBorder(),
                ),
                items: Weekday.values
                    .map(
                      (weekday) => DropdownMenuItem<Weekday>(
                        value: weekday,
                        child: Text(_weekdayLabel(weekday, l10n)),
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
                title: Text(l10n.settingsHealthSyncTitle),
                subtitle: Text(l10n.settingsHealthSyncSubtitle),
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
                      : Text(l10n.settingsExportButton),
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
                      : Text(l10n.settingsDeleteButton),
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

  String _weekdayLabel(Weekday day, AppLocalizations l10n) {
    switch (day) {
      case Weekday.monday:
        return l10n.weekdayMonday;
      case Weekday.tuesday:
        return l10n.weekdayTuesday;
      case Weekday.wednesday:
        return l10n.weekdayWednesday;
      case Weekday.thursday:
        return l10n.weekdayThursday;
      case Weekday.friday:
        return l10n.weekdayFriday;
      case Weekday.saturday:
        return l10n.weekdaySaturday;
      case Weekday.sunday:
        return l10n.weekdaySunday;
    }
  }

  Future<void> _onExportPressed() async {
    if (_isExporting) {
      return;
    }
    setState(() {
      _isExporting = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final snapshot = await widget.exportJson();
      final file = File(widget.exportPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(snapshot), flush: true);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsExportSuccess)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsExportError('$error')),
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

    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteDialogTitle),
          content: Text(l10n.settingsDeleteDialogMessage),
          actions: [
            TextButton(
              key: const Key('settings_cancel_delete_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              key: const Key('settings_confirm_delete_button'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonConfirm),
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
        SnackBar(content: Text(l10n.settingsDeleteSuccess)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDeleteError('$error')),
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
