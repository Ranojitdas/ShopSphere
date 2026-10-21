import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/entities/product_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/widgets/cart_app_bar_badge.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_reviews_list.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;
  final ProductEntity? initialProduct;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailsCubit>()
        ..loadProductDetails(productId, initialProduct: initialProduct),
      child: const _ProductDetailsView(),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final cubit = context.read<ProductDetailsCubit>();

        if (state.isNotFound) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Product Details'),
            ),
            body: AppEmptyView(
              icon: Icons.search_off_rounded,
              title: 'Product Not Found',
              subtitle: 'The product you are looking for does not exist or has been removed.',
              action: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Catalog'),
              ),
            ),
          );
        }

        if (state.isFailure && state.product == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Product Details'),
            ),
            body: AppErrorView(
              message: state.errorMessage ?? 'Failed to load product details.',
              onRetry: () => cubit.loadProductDetails(cubit.state.product?.id ?? 0),
            ),
          );
        }

        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: AppLoadingIndicator(message: 'Loading product details...'),
            ),
          );
        }

        final product = state.product!;
        final hasDiscount = product.discountPercentage > 0;
        final isOutOfStock = product.isOutOfStock;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: const [
              CartAppBarBadge(),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state, cubit, product, isOutOfStock),
          body: context.isCompact
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImageCarousel(
                        product: product,
                        onPageChanged: (index) => cubit.selectImage(index),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildDetailsContent(context, product, hasDiscount, isOutOfStock),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ProductImageCarousel(
                              product: product,
                              onPageChanged: (index) => cubit.selectImage(index),
                            ),
                          ),
                          const SizedBox(width: 36),
                          Expanded(
                            flex: 6,
                            child: _buildDetailsContent(
                              context,
                              product,
                              hasDiscount,
                              isOutOfStock,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    ProductEntity product,
    bool hasDiscount,
    bool isOutOfStock,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (product.brand ?? product.category).toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.star_rounded, color: AppColors.starFilled, size: 20),
            const SizedBox(width: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${product.reviews.length} reviews)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$${product.discountedPrice.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 10),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${product.discountPercentage.round()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOutOfStock
                ? AppColors.error.withValues(alpha: 0.1)
                : (product.stock < 10
                    ? AppColors.warning.withValues(alpha: 0.12)
                    : AppColors.success.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOutOfStock
                    ? Icons.cancel_outlined
                    : (product.stock < 10
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded),
                size: 18,
                color: isOutOfStock
                    ? AppColors.error
                    : (product.stock < 10 ? AppColors.warning : AppColors.success),
              ),
              const SizedBox(width: 8),
              Text(
                isOutOfStock
                    ? 'Currently Out of Stock'
                    : (product.stock < 10
                        ? 'Low Stock: Only ${product.stock} left!'
                        : 'In Stock (${product.stock} available)'),
                style: TextStyle(
                  color: isOutOfStock
                      ? AppColors.error
                      : (product.stock < 10 ? AppColors.warning : AppColors.success),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),
        _buildSpecifications(context, product),
        const SizedBox(height: 24),
        Text(
          'Customer Reviews (${product.reviews.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ProductReviewsList(reviews: product.reviews),
      ],
    );
  }

  Widget _buildSpecifications(BuildContext context, ProductEntity product) {
    final theme = Theme.of(context);

    final specs = <String, String?>{
      if (product.sku != null) 'SKU': product.sku,
      if (product.warrantyInformation != null) 'Warranty': product.warrantyInformation,
      if (product.shippingInformation != null) 'Shipping': product.shippingInformation,
      if (product.returnPolicy != null) 'Return Policy': product.returnPolicy,
      if (product.minimumOrderQuantity != null)
        'Min. Order Quantity': '${product.minimumOrderQuantity}',
    };

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Specifications',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...specs.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    entry.value ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ProductDetailsState state,
    ProductDetailsCubit cubit,
    ProductEntity product,
    bool isOutOfStock,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: isOutOfStock || state.quantity <= 1
                          ? null
                          : () => cubit.decrementQuantity(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${state.quantity}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: isOutOfStock || state.quantity >= product.stock
                          ? null
                          : () => cubit.incrementQuantity(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            final cartItem = CartItemEntity(
                              productId: product.id,
                              title: product.title,
                              price: product.price,
                              discountPercentage: product.discountPercentage,
                              quantity: state.quantity,
                              stock: product.stock,
                              thumbnail: product.thumbnail,
                            );
                            context.read<CartCubit>().addToCart(cartItem);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added ${state.quantity} ${state.quantity == 1 ? 'item' : 'items'} to cart',
                                ),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/cart'),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: Text(
                      isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
