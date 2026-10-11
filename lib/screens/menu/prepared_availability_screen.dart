import 'package:flutter/material.dart';

import '../../core/error_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../models/menu_management.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/app_retry.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

/// A daily kitchen task, separate from editing or archiving the catalog.
class PreparedAvailabilityScreen extends StatefulWidget {
  final MenuRepository menuRepository;
  final Listenable? refreshListenable;
  final VoidCallback? onDataChanged;

  const PreparedAvailabilityScreen({
    super.key,
    required this.menuRepository,
    this.refreshListenable,
    this.onDataChanged,
  });

  @override
  State<PreparedAvailabilityScreen> createState() =>
      _PreparedAvailabilityScreenState();
}

class _PreparedAvailabilityScreenState
    extends State<PreparedAvailabilityScreen> {
  late Future<List<MenuVariantRecord>> _variants;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
    widget.refreshListenable?.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant PreparedAvailabilityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable?.removeListener(_refresh);
      widget.refreshListenable?.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.refreshListenable?.removeListener(_refresh);
    super.dispose();
  }

  void _reload() {
    _variants = widget.menuRepository.getVariants();
  }

  void _refresh() {
    if (mounted) setState(_reload);
  }

  Future<void> _change(MenuVariantRecord item) async {
    final makeAvailable = !item.isAvailable;
    final saved = await showReasonDialog(
      context: context,
      title: makeAvailable
          ? 'Make ${item.itemName} available?'
          : 'Mark ${item.itemName} unavailable?',
      message: makeAvailable
          ? 'Staff can take orders for this prepared product again.'
          : 'All sizes of this prepared product will be disabled in the POS. '
              'Orders already in progress will be checked at payment.',
      confirmLabel: makeAvailable ? 'Make available' : 'Mark unavailable',
      reasonLabel: makeAvailable ? 'Why is it available again? *' : 'Reason *',
      onConfirm: (reason) async {
        if (reason.trim().length < 3 || reason.trim().length > 300) {
          return 'Enter a reason between 3 and 300 characters.';
        }
        try {
          await widget.menuRepository.setPreparedItemAvailability(
            menuItemId: item.menuItemId,
            isAvailable: makeAvailable,
            reason: reason,
          );
          return null;
        } catch (error) {
          return errorText(error);
        }
      },
    );

    if (!mounted || !saved) return;
    if (widget.onDataChanged == null) {
      _refresh();
    } else {
      widget.onDataChanged!();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.itemName} is now '
          '${makeAvailable ? 'available' : 'unavailable'}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Prepared item availability',
      subtitle: 'Update what the kitchen can prepare today.',
      action: IconButton(
        tooltip: 'Refresh availability',
        onPressed: _refresh,
        icon: const Icon(Icons.refresh),
      ),
      child: FutureBuilder<List<MenuVariantRecord>>(
        future: _variants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AppRetryPanel(
              message: 'Unable to load prepared products.',
              error: snapshot.error,
              fallback: _refresh,
            );
          }

          final byProduct = <String, List<MenuVariantRecord>>{};
          for (final variant in snapshot.data ?? <MenuVariantRecord>[]) {
            if (!variant.itemActive || !variant.isActive) continue;
            byProduct.putIfAbsent(variant.menuItemId, () => []).add(variant);
          }
          final prepared = byProduct.values
              .where(
                (variants) => variants.every(
                  (variant) => variant.inventoryTrackingMode == 'UNTRACKED',
                ),
              )
              .map((variants) => variants.first)
              .where(
                (item) =>
                    '${item.itemName} ${item.categoryName}'
                        .toLowerCase()
                        .contains(_search.trim().toLowerCase()),
              )
              .toList()
            ..sort((a, b) {
              final category = a.categoryName.compareTo(b.categoryName);
              return category != 0
                  ? category
                  : a.itemName.compareTo(b.itemName);
            });

          return Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search prepared products',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: prepared.isEmpty
                    ? Center(
                        child: Text(
                          _search.isEmpty
                              ? 'No active prepared products found.'
                              : 'No matching prepared products.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: prepared.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = prepared[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.itemName, style: AppTextStyles.h3),
                                  Text(
                                    item.categoryName,
                                    style: AppTextStyles.caption,
                                  ),
                                  if (!item.isAvailable &&
                                      item.availabilityReason.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Reason: ${item.availabilityReason}'),
                                  ],
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: [
                                      StatusBadge(
                                        item.isAvailable
                                            ? 'Available'
                                            : 'Unavailable',
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _change(item),
                                        child: Text(
                                          item.isAvailable
                                              ? 'Mark unavailable'
                                              : 'Make available',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
