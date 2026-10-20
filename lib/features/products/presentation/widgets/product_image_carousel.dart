import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/product_entity.dart';

class ProductImageCarousel extends StatefulWidget {
  final ProductEntity product;
  final ValueChanged<int>? onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.product,
    this.onPageChanged,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _images {
    if (widget.product.images.isNotEmpty) {
      return widget.product.images;
    }
    if (widget.product.thumbnail.isNotEmpty) {
      return [widget.product.thumbnail];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = _images;

    if (images.isEmpty) {
      return Container(
        height: 320,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded, size: 48),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              final isFirstImage = index == 0;

              final imageWidget = CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceContainerHighest,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_rounded, size: 48),
                ),
              );

              return Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: isFirstImage
                    ? Hero(
                        tag: 'product-image-${widget.product.id}',
                        child: imageWidget,
                      )
                    : imageWidget,
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) {
                final isSelected = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
