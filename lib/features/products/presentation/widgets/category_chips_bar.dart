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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAllChip = index == 0;
          final isSelected = isAllChip
              ? selectedCategory == null
              : selectedCategory == categories[index - 1].slug;
          final labelText = isAllChip
              ? 'All Products'
              : categories[index - 1].name;
          final slug = isAllChip ? null : categories[index - 1].slug;

          final textColor = isSelected
              ? (isDark ? theme.colorScheme.onPrimary : Colors.white)
              : theme.colorScheme.onSurface;

          return ChoiceChip(
            label: Text(
              labelText,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => onCategorySelected(slug),
          );
        },
      ),
    );
  }
}
