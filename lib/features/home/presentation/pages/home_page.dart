import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/adaptive_navigation_scaffold.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../../products/presentation/cubit/product_list_state.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../products/presentation/widgets/category_chips_bar.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_grid_shimmer.dart';
import '../../../products/presentation/widgets/product_search_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: BlocProvider(
        create: (_) => sl<ProductListCubit>()..loadInitialCatalog(),
        child: AdaptiveNavigationScaffold(
          currentIndex: _currentTab,
          onNavigationChanged: (index) {
            setState(() {
              _currentTab = index;
            });
          },
          children: [
            const _HomeCatalogView(),
            CartPage(
              isEmbedded: true,
              onContinueShopping: () {
                setState(() {
                  _currentTab = 0;
                });
              },
            ),
            const ProfilePage(isEmbedded: true),
          ],
        ),
      ),
    );
  }
}

class _HomeCatalogView extends StatefulWidget {
  const _HomeCatalogView();

  @override
  State<_HomeCatalogView> createState() => _HomeCatalogViewState();
}

class _HomeCatalogViewState extends State<_HomeCatalogView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<ProductListCubit>().loadMoreProducts();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductListCubit>().clearSearch();
  }

  void _showSortBottomSheet(BuildContext context) {
    final cubit = context.read<ProductListCubit>();
    final currentSort = cubit.state.sortOption;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Sort Products',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ...ProductSortOption.values.map((option) {
                  final isSelected = option == currentSort;
                  return ListTile(
                    title: Text(option.label),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      cubit.setSortOption(option);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = context.isCompact
        ? 2
        : (context.isMedium ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ShopSphere',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ProductListCubit, ProductListState>(
            buildWhen: (previous, current) =>
                previous.sortOption != current.sortOption,
            builder: (context, state) {
              final isSorted =
                  state.sortOption != ProductSortOption.defaultSort;
              return IconButton(
                icon: Badge(
                  isLabelVisible: isSorted,
                  smallSize: 8,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.tune_rounded),
                ),
                tooltip: isSorted
                    ? 'Sort: ${state.sortOption.label}'
                    : 'Sort Options',
                onPressed: () => _showSortBottomSheet(context),
              );
            },
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                tooltip:
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                icon: Icon(
                  isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<ProductListCubit, ProductListState>(
        builder: (context, state) {
          final cubit = context.read<ProductListCubit>();

          return Column(
            children: [
              ProductSearchBar(
                controller: _searchController,
                hasQuery: state.isSearching || _searchController.text.isNotEmpty,
                onChanged: (val) => cubit.onSearchQueryChanged(val),
                onClear: _clearSearch,
              ),
              if (state.isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Search: "${state.searchQuery}" (${state.total} results)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Text(
                          'Clear',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (state.categories.isNotEmpty) ...[
                const SizedBox(height: 4),
                CategoryChipsBar(
                  categories: state.categories,
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: (slug) {
                    _searchController.clear();
                    cubit.selectCategory(slug);
                  },
                ),
                const SizedBox(height: 4),
              ],
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isInitialLoading) {
                      return const ProductGridShimmer();
                    }

                    if (state.isFailure) {
                      return AppErrorView(
                        message: state.errorMessage ?? 'Failed to load products.',
                        onRetry: () => cubit.refresh(),
                      );
                    }

                    if (state.isEmpty) {
                      if (state.isSearching) {
                        return AppEmptyView(
                          title: 'No Matching Products',
                          subtitle: 'We couldn\'t find any items matching "${state.searchQuery}". Try a different keyword.',
                          action: OutlinedButton(
                            onPressed: _clearSearch,
                            child: const Text('Clear Search'),
                          ),
                        );
                      }

                      return AppEmptyView(
                        title: 'No Products Found',
                        subtitle: 'No items found in this category.',
                        action: OutlinedButton(
                          onPressed: () => cubit.selectCategory(null),
                          child: const Text('Reset Filters'),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => cubit.refresh(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.70,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = state.products[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsPage(
                                            productId: product.id,
                                            initialProduct: product,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: state.products.length,
                              ),
                            ),
                          ),
                          if (state.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: AppLoadingIndicator(
                                  message: 'Loading more products...',
                                ),
                              ),
                            ),
                        ],
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
