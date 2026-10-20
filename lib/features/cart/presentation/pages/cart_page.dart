import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Shopping Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartCubit>().clearCart();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _onProceedToCheckout(BuildContext context) {
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartLoaded && state.notificationMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.notificationMessage!),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CartCubit>();
        final cart = cubit.currentCart;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (cart.isNotEmpty)
                  Text(
                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            actions: [
              if (cart.isNotEmpty)
                IconButton(
                  tooltip: 'Clear Cart',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _showClearCartDialog(context),
                ),
            ],
          ),
          body: state is CartLoading && cart.isEmpty
              ? const Center(
                  child: AppLoadingIndicator(message: 'Loading cart...'),
                )
              : cart.isEmpty
                  ? AppEmptyView(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your Cart is Empty',
                      subtitle:
                          'Looks like you haven\'t added any products to your cart yet.',
                      action: FilledButton.icon(
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Start Shopping'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  : context.isCompact
                      ? Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                physics: const BouncingScrollPhysics(),
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return CartItemTile(
                                    item: item,
                                    onIncrement: () => cubit.updateQuantity(
                                      item.productId,
                                      item.quantity + 1,
                                    ),
                                    onDecrement: () => cubit.updateQuantity(
                                      item.productId,
                                      item.quantity - 1,
                                    ),
                                    onRemove: () =>
                                        cubit.removeFromCart(item.productId),
                                  );
                                },
                              ),
                            ),
                            CartSummaryCard(
                              cart: cart,
                              onCheckout: () => _onProceedToCheckout(context),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                physics: const BouncingScrollPhysics(),
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return CartItemTile(
                                    item: item,
                                    onIncrement: () => cubit.updateQuantity(
                                      item.productId,
                                      item.quantity + 1,
                                    ),
                                    onDecrement: () => cubit.updateQuantity(
                                      item.productId,
                                      item.quantity - 1,
                                    ),
                                    onRemove: () =>
                                        cubit.removeFromCart(item.productId),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: CartSummaryCard(
                                    cart: cart,
                                    onCheckout: () =>
                                        _onProceedToCheckout(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
        );
      },
    );
  }
}
