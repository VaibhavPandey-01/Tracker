import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../domain/models/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showAddCategorySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddCategorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  NeumorphicContainer(
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFFB8B8C0),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5F5F7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 32),

              // ── Grid of Categories ──────────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, i) {
                  if (i == categories.length) {
                    // Add category button tile
                    return GestureDetector(
                      onTap: () => _showAddCategorySheet(context, ref),
                      child: Column(
                        children: [
                          Expanded(
                            child: NeumorphicContainer(
                              borderRadius: 24,
                              child: const Center(
                                child: Icon(Icons.add, size: 24, color: Color(0xFFB8B8C0)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add New',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8A93),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }

                  final cat = categories[i];
                  return Column(
                    children: [
                      Expanded(
                        child: NeumorphicContainer(
                          borderRadius: 24,
                          onTap: () {
                            // Expand/options (delete) Category
                            _showDeleteDialog(context, ref, cat);
                          },
                          child: Center(
                            child: Icon(cat.icon, size: 22, color: const Color(0xFFB8B8C0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        style: tt.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Category cat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0A0C),
          title: Text('Delete ${cat.name}?'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A93))),
            ),
            TextButton(
              onPressed: () {
                ref.read(categoriesProvider.notifier).delete(cat.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        );
      },
    );
  }
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_outlined;

  final _icons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.movie,
    Icons.local_hospital,
    Icons.receipt_long,
    Icons.shopping_cart,
    Icons.school,
    Icons.flight,
    Icons.spa,
    Icons.fitness_center,
    Icons.sports_esports,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(categoriesProvider.notifier);
    notifier.add(Category(
      id: notifier.generateId(),
      name: name,
      icon: _selectedIcon,
      color: Colors.white, // In monochrome, color is unused
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Category',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          NeumorphicTextField(
            labelText: 'Category Name',
            hintText: 'e.g. Subscriptions',
            controller: _nameController,
          ),
          const SizedBox(height: 20),
          Text(
            'Icon Type',
            style: tt.labelMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, i) {
              final icon = _icons[i];
              final isSelected = _selectedIcon == icon;

              return NeumorphicContainer(
                borderRadius: 12,
                isInset: isSelected,
                onTap: () => setState(() => _selectedIcon = icon),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          NeumorphicButton(
            onTap: _save,
            child: const Text(
              'Save Category',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
