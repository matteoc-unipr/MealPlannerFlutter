import 'package:flutter/material.dart';

/// Guides the user through the available ways of adding a meal entry.
class AddMealFlow extends StatelessWidget {
  const AddMealFlow({
    super.key,
    required this.onScan,
    required this.onSearch,
    required this.onRecipes,
    required this.onQuickAdd,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(24),
  });

  /// Callback invoked when the user chooses the barcode scanning option.
  final VoidCallback onScan;

  /// Callback invoked when the user chooses to search for food items.
  final VoidCallback onSearch;

  /// Callback invoked when the user wants to browse saved recipes.
  final VoidCallback onRecipes;

  /// Callback invoked when the user wants to log a quick entry.
  final VoidCallback onQuickAdd;

  /// Optional title displayed above the available actions.
  final String? title;

  /// Optional subtitle providing additional context.
  final String? subtitle;

  /// Padding applied around the action list.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerWidgets = <Widget>[];

    if (title != null) {
      headerWidgets.add(
        Text(
          title!,
          style: theme.textTheme.headlineSmall,
        ),
      );
    }

    if (subtitle != null) {
      headerWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final options = <_FlowOption>[
      _FlowOption(
        label: 'Scansiona',
        description: 'Inquadra il codice a barre di un prodotto.',
        icon: Icons.qr_code_scanner,
        onTap: onScan,
      ),
      _FlowOption(
        label: 'Cerca',
        description: 'Trova un alimento nel catalogo.',
        icon: Icons.search,
        onTap: onSearch,
      ),
      _FlowOption(
        label: 'Ricette',
        description: 'Aggiungi una delle tue ricette salvate.',
        icon: Icons.book_outlined,
        onTap: onRecipes,
      ),
      _FlowOption(
        label: 'Rapidi',
        description: 'Registra velocemente calorie o note.',
        icon: Icons.bolt_outlined,
        onTap: onQuickAdd,
      ),
    ];

    return ListView(
      padding: padding,
      shrinkWrap: true,
      children: [
        if (headerWidgets.isNotEmpty) ...[
          ...headerWidgets,
          const SizedBox(height: 24),
        ],
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AddMealOption(option: option),
          ),
        ),
      ],
    );
  }
}

class _FlowOption {
  const _FlowOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
}

class _AddMealOption extends StatelessWidget {
  const _AddMealOption({required this.option});

  final _FlowOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: option.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(option.icon),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
