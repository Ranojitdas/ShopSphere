import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/cart_state.dart';
import '../utils/responsive_layout.dart';

class AdaptiveNavigationScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<Widget> children;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.children,
  });

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of ShopSphere?',
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
              context.read<AuthCubit>().logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) {
        final prevCount =
            previous is CartLoaded ? previous.cart.totalItemCount : 0;
        final currCount =
            current is CartLoaded ? current.cart.totalItemCount : 0;
        return prevCount != currCount;
      },
      builder: (context, cartState) {
        final cartCount =
            cartState is CartLoaded ? cartState.cart.totalItemCount : 0;

        if (context.isCompact) {
          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: children,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onNavigationChanged,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Catalog',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: context.isExpanded,
                minExtendedWidth: 200,
                selectedIndex: currentIndex,
                onDestinationSelected: onNavigationChanged,
                leading: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      if (context.isExpanded) ...[
                        const SizedBox(width: 12),
                        Text(
                          'ShopSphere',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Sign Out',
                        color: theme.colorScheme.error,
                        onPressed: () => _showSignOutDialog(context),
                      ),
                    ),
                  ),
                ),
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.storefront_outlined),
                    selectedIcon: Icon(Icons.storefront_rounded),
                    label: Text('Catalog'),
                  ),
                  NavigationRailDestination(
                    icon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_bag_rounded),
                    ),
                    label: const Text('Cart'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: IndexedStack(
                  index: currentIndex,
                  children: children,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
