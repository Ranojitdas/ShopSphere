import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../../products/presentation/cubit/product_list_state.dart';
import '../../../products/presentation/widgets/category_chips_bar.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_grid_shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        child: const _HomeCatalogView(),
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<ProductListCubit>().loadMoreProducts();
    }
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
    final crossAxisCount = context.isCompact
        ? 2
        : (context.isMedium ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopSphere',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Options',
            onPressed: () => _showSortBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<ProductListCubit, ProductListState>(
        builder: (context, state) {
          final cubit = context.read<ProductListCubit>();

          return Column(
            children: [
              if (state.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                CategoryChipsBar(
                  categories: state.categories,
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: (slug) => cubit.selectCategory(slug),
                ),
                const SizedBox(height: 8),
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
                                    onTap: () {},
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
