import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

class CategoryChipsBar extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryChipsBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategory == null;
            return ChoiceChip(
              label: const Text('All Products'),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category.slug;

          return ChoiceChip(
            label: Text(category.name),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onCategorySelected(category.slug),
          );
        },
      ),
    );
  }
}
