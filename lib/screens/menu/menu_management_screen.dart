import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../models/menu_management.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class MenuManagementScreen extends StatefulWidget {
  final MenuRepository menuRepository;

  const MenuManagementScreen({
    super.key,
    required this.menuRepository,
  });

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  late Future<List<MenuVariantRecord>> _variantsFuture;
  String _search = '';
  String _categoryFilter = 'All Categories';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _variantsFuture = widget.menuRepository.getVariants();
  }

  void _refresh() {
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Menu Management',
      action: ElevatedButton.icon(
        onPressed: _showCreateProduct,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Product'),
      ),
      child: FutureBuilder<List<MenuVariantRecord>>(
        future: _variantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load menu.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final all = snapshot.data ?? const <MenuVariantRecord>[];
          final categories = all
              .map((variant) => variant.categoryName)
              .toSet()
              .toList()
            ..sort();

          if (_categoryFilter != 'All Categories' &&
              !categories.contains(_categoryFilter)) {
            _categoryFilter = 'All Categories';
          }

          final query = _search.trim().toLowerCase();
          final variants = all.where((variant) {
            final matchesSearch = query.isEmpty ||
                variant.itemName.toLowerCase().contains(query) ||
                variant.variantName.toLowerCase().contains(query) ||
                variant.sku.toLowerCase().contains(query);
            final matchesCategory =
                _categoryFilter == 'All Categories' ||
                    variant.categoryName == _categoryFilter;
            return matchesSearch && matchesCategory;
          }).toList();

          return Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final search = TextField(
                    onChanged: (value) => setState(() => _search = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search product, variant, or SKU...',
                    ),
                  );
                  final category = DropdownButtonFormField<String>(
                    initialValue: _categoryFilter,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: 'All Categories',
                        child: Text('All Categories'),
                      ),
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _categoryFilter = value);
                    },
                  );

                  if (constraints.maxWidth < 620) {
                    return Column(
                      children: [
                        search,
                        const SizedBox(height: 12),
                        category,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: 12),
                      SizedBox(width: 220, child: category),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Expanded(
                child: variants.isEmpty
                    ? const Center(child: Text('No menu variants found.'))
                    : SingleChildScrollView(
                        child: DataTableCard(
                          headers: const [
                            'Product',
                            'Variant',
                            'SKU',
                            'Price',
                            'Inventory',
                            'Status',
                            'Actions',
                          ],
                          flexes: const [3, 2, 2, 2, 3, 2, 2],
                          rows: variants
                              .map(
                                (variant) => [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        variant.itemName,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      Text(
                                        variant.categoryName,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    variant.variantName,
                                    style: AppTextStyles.body,
                                  ),
                                  Text(
                                    variant.sku.isEmpty ? '—' : variant.sku,
                                    style: AppTextStyles.body,
                                  ),
                                  Text(
                                    _money(variant.price),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    _inventorySummary(variant),
                                    style: AppTextStyles.body,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: StatusBadge(
                                      variant.isActive
                                          ? 'Active'
                                          : 'Inactive',
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit Variant',
                                        onPressed: () =>
                                            _showEditVariant(variant),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 19,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Add Variant',
                                        onPressed: () =>
                                            _showAddVariant(variant),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 19,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Modifiers',
                                        onPressed: () =>
                                            _showModifiers(variant),
                                        icon: const Icon(
                                          Icons.tune_outlined,
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                              .toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateProduct() async {
    final categories = await widget.menuRepository.getCategories();
    final inventory = await widget.menuRepository.getInventoryOptions();

    if (!mounted || categories.isEmpty) return;

    await _showVariantEditor(
      title: 'Add Product',
      categories: categories,
      inventory: inventory,
      existing: null,
      addVariantTo: null,
    );
  }

  Future<void> _showAddVariant(MenuVariantRecord parent) async {
    final categories = await widget.menuRepository.getCategories();
    final inventory = await widget.menuRepository.getInventoryOptions();

    if (!mounted) return;

    await _showVariantEditor(
      title: 'Add Variant to ${parent.itemName}',
      categories: categories,
      inventory: inventory,
      existing: null,
      addVariantTo: parent,
    );
  }

  Future<void> _showEditVariant(MenuVariantRecord variant) async {
    final results = await Future.wait([
      widget.menuRepository.getCategories(),
      widget.menuRepository.getInventoryOptions(),
      widget.menuRepository.getRecipeComponents(variant.variantId),
    ]);

    if (!mounted) return;

    await _showVariantEditor(
      title: 'Edit ${variant.itemName} — ${variant.variantName}',
      categories: results[0] as List<MenuCategoryOption>,
      inventory: results[1] as List<MenuInventoryOption>,
      existing: variant,
      addVariantTo: null,
      initialRecipe: results[2] as List<MenuRecipeComponent>,
    );
  }

  Future<void> _showVariantEditor({
    required String title,
    required List<MenuCategoryOption> categories,
    required List<MenuInventoryOption> inventory,
    required MenuVariantRecord? existing,
    required MenuVariantRecord? addVariantTo,
    List<MenuRecipeComponent> initialRecipe = const [],
  }) async {
    final isEditing = existing != null;
    final isAddingVariant = addVariantTo != null;

    final itemNameController = TextEditingController(
      text: existing?.itemName ?? addVariantTo?.itemName ?? '',
    );
    final variantNameController = TextEditingController(
      text: existing?.variantName ?? '',
    );
    final skuController = TextEditingController(text: existing?.sku ?? '');
    final priceController = TextEditingController(
      text: existing == null ? '' : existing.price.toStringAsFixed(2),
    );

    String categoryId =
        existing?.categoryId ?? addVariantTo?.categoryId ?? categories.first.id;
    String inventoryMode =
        existing?.inventoryTrackingMode ?? 'UNTRACKED';
    String finishedInventoryId =
        existing?.finishedInventoryItemId ?? '';
    bool isActive = existing?.isActive ?? true;
    List<MenuRecipeComponent> recipe =
        List<MenuRecipeComponent>.from(initialRecipe);

    String? errorMessage;
    StateSetter? updateDialogState;

    await showPrototypeDialog(
      context: context,
      title: title,
      width: 720,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  enabled: !isAddingVariant,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: isAddingVariant
                      ? null
                      : (value) {
                          if (value == null) return;
                          setDialogState(() => categoryId = value);
                        },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: variantNameController,
                        decoration: const InputDecoration(
                          labelText: 'Variant Name *',
                          hintText: 'Regular, Small, Large, 330 ml Can...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: skuController,
                        decoration: const InputDecoration(
                          labelText: 'SKU',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                    prefixText: '₱',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: inventoryMode,
                  decoration: const InputDecoration(
                    labelText: 'Inventory Tracking',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'UNTRACKED',
                      child: Text('Untracked'),
                    ),
                    DropdownMenuItem(
                      value: 'FINISHED_GOOD',
                      child: Text('Finished Good'),
                    ),
                    DropdownMenuItem(
                      value: 'RECIPE',
                      child: Text('Recipe / Ingredients'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      inventoryMode = value;
                      errorMessage = null;
                    });
                  },
                ),
                if (inventoryMode == 'FINISHED_GOOD') ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: finishedInventoryId.isEmpty
                        ? null
                        : finishedInventoryId,
                    decoration: const InputDecoration(
                      labelText: 'Linked Inventory Item *',
                    ),
                    items: inventory
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.name} — ${_qty(item.currentQuantity)} ${item.unitCode}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => finishedInventoryId = value);
                    },
                  ),
                ],
                if (inventoryMode == 'RECIPE') ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recipe Components',
                          style: AppTextStyles.h3,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final component =
                              await _showRecipeComponentDialog(
                            dialogContext,
                            inventory,
                          );
                          if (component == null) return;

                          setDialogState(() {
                            recipe.removeWhere(
                              (entry) =>
                                  entry.inventoryItemId ==
                                  component.inventoryItemId,
                            );
                            recipe.add(component);
                          });
                        },
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text('Add Ingredient'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (recipe.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No ingredients configured yet.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    )
                  else
                    for (final component in recipe)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                component.inventoryItemName,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Text(
                              '${_qty(component.quantityBaseUom)} ${component.unitCode}',
                              style: AppTextStyles.body,
                            ),
                            if (component.wastagePercent > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                '+${_qty(component.wastagePercent)}% waste',
                                style: AppTextStyles.caption,
                              ),
                            ],
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () {
                                setDialogState(() {
                                  recipe.removeWhere(
                                    (entry) =>
                                        entry.inventoryItemId ==
                                        component.inventoryItemId,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
                if (isEditing) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Variant Active'),
                    subtitle: const Text(
                      'Inactive variants are hidden from the POS.',
                    ),
                    value: isActive,
                    onChanged: (value) =>
                        setDialogState(() => isActive = value),
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final price =
                double.tryParse(priceController.text.trim());

            if (itemNameController.text.trim().isEmpty ||
                variantNameController.text.trim().isEmpty ||
                price == null ||
                price < 0) {
              updateDialogState?.call(() {
                errorMessage =
                    'Product name, variant name, and a valid price are required.';
              });
              return;
            }

            if (inventoryMode == 'FINISHED_GOOD' &&
                finishedInventoryId.isEmpty) {
              updateDialogState?.call(() {
                errorMessage = 'Select the linked inventory item.';
              });
              return;
            }

            if (inventoryMode == 'RECIPE' && recipe.isEmpty) {
              updateDialogState?.call(() {
                errorMessage = 'Add at least one recipe ingredient.';
              });
              return;
            }

            try {
              if (existing != null) {
                await widget.menuRepository.updateVariant(
                  variant: existing,
                  itemName: itemNameController.text.trim(),
                  categoryId: categoryId,
                  variantName: variantNameController.text.trim(),
                  sku: skuController.text.trim(),
                  price: price,
                  isActive: isActive,
                  inventoryMode: inventoryMode,
                  finishedInventoryItemId: finishedInventoryId,
                  recipe: recipe,
                );
              } else if (addVariantTo != null) {
                await widget.menuRepository.addVariant(
                  menuItemId: addVariantTo.menuItemId,
                  variantName: variantNameController.text.trim(),
                  sku: skuController.text.trim(),
                  price: price,
                  inventoryMode: inventoryMode,
                  finishedInventoryItemId: finishedInventoryId,
                  recipe: recipe,
                );
              } else {
                await widget.menuRepository.createMenuItemWithVariant(
                  itemName: itemNameController.text.trim(),
                  categoryId: categoryId,
                  variantName: variantNameController.text.trim(),
                  sku: skuController.text.trim(),
                  price: price,
                  inventoryMode: inventoryMode,
                  finishedInventoryItemId: finishedInventoryId,
                  recipe: recipe,
                );
              }

              if (!mounted) return;
              Navigator.pop(context);
              _refresh();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu configuration saved.'),
                ),
              );
            } on PostgrestException catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );

    itemNameController.dispose();
    variantNameController.dispose();
    skuController.dispose();
    priceController.dispose();
  }

  Future<MenuRecipeComponent?> _showRecipeComponentDialog(
    BuildContext context,
    List<MenuInventoryOption> inventory,
  ) async {
    if (inventory.isEmpty) return null;

    String inventoryId = inventory.first.id;
    final quantityController = TextEditingController();
    final wastageController = TextEditingController(text: '0');
    String? errorMessage;

    final result = await showDialog<MenuRecipeComponent>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) {
          final selected =
              inventory.firstWhere((item) => item.id == inventoryId);

          return AlertDialog(
            title: const Text(
              'Add Recipe Ingredient',
              style: AppTextStyles.h2,
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: inventoryId,
                    decoration: const InputDecoration(
                      labelText: 'Inventory Item',
                    ),
                    items: inventory
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.name} (${item.unitCode})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => inventoryId = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText:
                          'Quantity per sale (${selected.unitCode})',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: wastageController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Wastage %',
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final quantity =
                      double.tryParse(quantityController.text.trim());
                  final wastage =
                      double.tryParse(wastageController.text.trim());

                  if (quantity == null ||
                      quantity <= 0 ||
                      wastage == null ||
                      wastage < 0) {
                    setDialogState(() {
                      errorMessage =
                          'Enter a quantity above 0 and a valid wastage percentage.';
                    });
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    MenuRecipeComponent(
                      inventoryItemId: selected.id,
                      inventoryItemName: selected.name,
                      unitCode: selected.unitCode,
                      quantityBaseUom: quantity,
                      wastagePercent: wastage,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    quantityController.dispose();
    wastageController.dispose();
    return result;
  }


  Future<void> _showModifiers(MenuVariantRecord variant) async {
    final results = await Future.wait([
      widget.menuRepository.getModifierGroupsForMenuItem(
        variant.menuItemId,
      ),
      widget.menuRepository.getInventoryOptions(),
    ]);

    if (!mounted) return;

    final groups = results[0] as List<MenuModifierGroupRecord>;
    final inventory = results[1] as List<MenuInventoryOption>;

    await showPrototypeDialog(
      context: context,
      title: 'Modifiers — ${variant.itemName}',
      width: 720,
      content: SizedBox(
        height: 430,
        child: groups.isEmpty
            ? Center(
                child: Text(
                  'No modifier groups configured yet.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 24),
                itemBuilder: (_, index) {
                  final group = groups[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.groupName,
                                  style: AppTextStyles.h3,
                                ),
                                Text(
                                  _modifierGroupRule(group),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            group.isActive ? 'Active' : 'Inactive',
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Edit Group',
                            onPressed: () {
                              Navigator.pop(context);
                              _showModifierGroupEditor(
                                variant,
                                existing: group,
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 19,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Add Modifier',
                            onPressed: () {
                              Navigator.pop(context);
                              _showModifierEditor(
                                variant,
                                group,
                                inventory,
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (group.modifiers.isEmpty)
                        Text(
                          'No options in this group.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray500,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: group.modifiers
                              .map(
                                (modifier) => ActionChip(
                                  avatar: Icon(
                                    modifier.isActive
                                        ? Icons.check_circle_outline
                                        : Icons.hide_source_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    modifier.priceDelta == 0
                                        ? modifier.name
                                        : '${modifier.name} (+${_money(modifier.priceDelta)})',
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showModifierEditor(
                                      variant,
                                      group,
                                      inventory,
                                      existing: modifier,
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showModifierGroupEditor(variant);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Modifier Group'),
        ),
      ],
    );
  }

  Future<void> _showModifierGroupEditor(
    MenuVariantRecord variant, {
    MenuModifierGroupRecord? existing,
  }) async {
    final nameController = TextEditingController(
      text: existing?.groupName ?? '',
    );
    final minController = TextEditingController(
      text: '${existing?.minSelections ?? 0}',
    );
    final maxController = TextEditingController(
      text: existing?.maxSelections?.toString() ?? '',
    );
    var required = existing?.isRequired ?? false;
    var active = existing?.isActive ?? true;
    String? errorMessage;
    StateSetter? dialogSetState;

    await showPrototypeDialog(
      context: context,
      title: existing == null
          ? 'Add Modifier Group'
          : 'Edit Modifier Group',
      width: 540,
      content: StatefulBuilder(
        builder: (_, setDialogState) {
          dialogSetState = setDialogState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name *',
                  hintText: 'e.g. Milk Choice, Add-ons',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Selections',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximum',
                        hintText: 'Blank = no limit',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Required'),
                value: required,
                onChanged: (value) {
                  setDialogState(() {
                    required = value;
                    if (required &&
                        (int.tryParse(minController.text) ?? 0) < 1) {
                      minController.text = '1';
                    }
                  });
                },
              ),
              if (existing != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: active,
                  onChanged: (value) =>
                      setDialogState(() => active = value),
                ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final min = int.tryParse(minController.text.trim());
            final maxText = maxController.text.trim();
            final max = maxText.isEmpty ? null : int.tryParse(maxText);

            if (name.isEmpty ||
                min == null ||
                min < 0 ||
                (maxText.isNotEmpty && max == null) ||
                (max != null && (max < 1 || max < min)) ||
                (required && min < 1)) {
              dialogSetState?.call(() {
                errorMessage =
                    'Check the name and minimum/maximum selection rules.';
              });
              return;
            }

            try {
              if (existing == null) {
                await widget.menuRepository.createModifierGroup(
                  menuItemId: variant.menuItemId,
                  groupName: name,
                  minSelections: min,
                  maxSelections: max,
                  isRequired: required,
                );
              } else {
                await widget.menuRepository.updateModifierGroup(
                  groupId: existing.groupId,
                  groupName: name,
                  minSelections: min,
                  maxSelections: max,
                  isRequired: required,
                  isActive: active,
                );
              }

              if (!mounted) return;
              Navigator.pop(context);
              _showModifiers(variant);
            } on PostgrestException catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: Text(existing == null ? 'Create Group' : 'Save Changes'),
        ),
      ],
    );

    nameController.dispose();
    minController.dispose();
    maxController.dispose();
  }

  Future<void> _showModifierEditor(
    MenuVariantRecord variant,
    MenuModifierGroupRecord group,
    List<MenuInventoryOption> inventory, {
    MenuModifierRecord? existing,
  }) async {
    final nameController = TextEditingController(
      text: existing?.name ?? '',
    );
    final priceController = TextEditingController(
      text: existing == null
          ? '0'
          : existing.priceDelta.toStringAsFixed(2),
    );

    var active = existing?.isActive ?? true;
    var recipe = existing == null
        ? <MenuRecipeComponent>[]
        : await widget.menuRepository.getModifierRecipeComponents(
            existing.id,
          );

    if (!mounted) return;

    String? errorMessage;
    StateSetter? dialogSetState;

    await showPrototypeDialog(
      context: context,
      title: existing == null
          ? 'Add Modifier — ${group.groupName}'
          : 'Edit ${existing.name}',
      width: 650,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          dialogSetState = setDialogState;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Modifier Name *',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Additional Price',
                    prefixText: '₱',
                  ),
                ),
                if (existing != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: active,
                    onChanged: (value) =>
                        setDialogState(() => active = value),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Inventory Recipe',
                        style: AppTextStyles.h3,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: inventory.isEmpty
                          ? null
                          : () async {
                              final component =
                                  await _showRecipeComponentDialog(
                                dialogContext,
                                inventory,
                              );
                              if (component == null) return;

                              setDialogState(() {
                                recipe = [
                                  ...recipe.where(
                                    (item) =>
                                        item.inventoryItemId !=
                                        component.inventoryItemId,
                                  ),
                                  component,
                                ];
                              });
                            },
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Add Component'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recipe.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No inventory ingredient is deducted by this modifier.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  )
                else
                  for (final component in recipe)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(component.inventoryItemName),
                      subtitle: Text(
                        '${_qty(component.quantityBaseUom)} '
                        '${component.unitCode} per selection'
                        '${component.wastagePercent > 0 ? ' • ${_qty(component.wastagePercent)}% wastage' : ''}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setDialogState(() {
                            recipe = recipe
                                .where(
                                  (item) =>
                                      item.inventoryItemId !=
                                      component.inventoryItemId,
                                )
                                .toList();
                          });
                        },
                      ),
                    ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final price =
                double.tryParse(priceController.text.trim());

            if (name.isEmpty || price == null) {
              dialogSetState?.call(() {
                errorMessage =
                    'Enter a modifier name and a valid price.';
              });
              return;
            }

            try {
              if (existing == null) {
                await widget.menuRepository.createModifier(
                  groupId: group.groupId,
                  name: name,
                  priceDelta: price,
                  recipe: recipe,
                );
              } else {
                await widget.menuRepository.updateModifier(
                  modifierId: existing.id,
                  name: name,
                  priceDelta: price,
                  isActive: active,
                  recipe: recipe,
                );
              }

              if (!mounted) return;
              Navigator.pop(context);
              _showModifiers(variant);
            } on PostgrestException catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: Text(existing == null ? 'Add Modifier' : 'Save Changes'),
        ),
      ],
    );

    nameController.dispose();
    priceController.dispose();
  }

  String _modifierGroupRule(MenuModifierGroupRecord group) {
    final max = group.maxSelections;
    if (max == null) {
      return 'Minimum ${group.minSelections}'
          '${group.isRequired ? ' • Required' : ''}';
    }
    if (group.minSelections == max) {
      return 'Select exactly $max'
          '${group.isRequired ? ' • Required' : ''}';
    }
    return 'Select ${group.minSelections}–$max'
        '${group.isRequired ? ' • Required' : ''}';
  }

  String _inventorySummary(MenuVariantRecord variant) {
    switch (variant.inventoryTrackingMode) {
      case 'FINISHED_GOOD':
        return variant.finishedInventoryName.isEmpty
            ? 'Finished Good'
            : 'Finished: ${variant.finishedInventoryName}';
      case 'RECIPE':
        return 'Recipe • ${variant.recipeComponentCount} component(s)';
      default:
        return 'Untracked';
    }
  }

  static String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  static String _qty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}
