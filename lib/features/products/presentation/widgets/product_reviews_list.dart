import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_review_entity.dart';

class ProductReviewsList extends StatelessWidget {
  final List<ProductReviewEntity> reviews;

  const ProductReviewsList({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No reviews yet for this product.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final formattedDate =
            '${review.date.day}/${review.date.month}/${review.date.year}';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Text(
                      review.reviewerName.isNotEmpty
                          ? review.reviewerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.reviewerName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.starFilled,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                review.comment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
