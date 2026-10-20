import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  static const int pageSize = 20;
  Timer? _debounceTimer;

  ProductListCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
    required this.searchProductsUseCase,
  }) : super(const ProductListState());

  Future<void> loadInitialCatalog() async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      errorMessage: () => null,
    ));

    await Future.wait([
      _fetchCategories(),
      _fetchFirstPage(),
    ]);
  }

  Future<void> _fetchCategories() async {
    final result = await getCategoriesUseCase();
    if (isClosed) return;

    result.fold(
      (_) {},
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  Future<void> _fetchFirstPage() async {
    final isCategory = state.selectedCategory != null && state.selectedCategory!.isNotEmpty;

    final result = isCategory
        ? await getProductsByCategoryUseCase(
            categorySlug: state.selectedCategory!,
            limit: pageSize,
            skip: 0,
            sortBy: state.sortOption.sortBy,
            order: state.sortOption.order,
          )
        : await getProductsUseCase(
            limit: pageSize,
            skip: 0,
            sortBy: state.sortOption.sortBy,
            order: state.sortOption.order,
          );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: () => failure.message,
      )),
      (page) => emit(state.copyWith(
        status: ProductListStatus.success,
        products: page.products,
        total: page.total,
        skip: page.products.length,
        hasMore: page.hasMore,
        errorMessage: () => null,
      )),
    );
  }

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (state.searchQuery.isNotEmpty) {
        emit(state.copyWith(
          searchQuery: () => '',
          status: ProductListStatus.loading,
          products: [],
          skip: 0,
          hasMore: true,
          errorMessage: () => null,
        ));
        _fetchFirstPage();
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(trimmed);
    });
  }

  Future<void> _executeSearch(String query) async {
    emit(state.copyWith(
      searchQuery: () => query,
      status: ProductListStatus.loading,
      products: [],
      skip: 0,
      hasMore: true,
      errorMessage: () => null,
    ));

    final result = await searchProductsUseCase(
      query: query,
      limit: pageSize,
      skip: 0,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: () => failure.message,
      )),
      (page) => emit(state.copyWith(
        status: ProductListStatus.success,
        products: page.products,
        total: page.total,
        skip: page.products.length,
        hasMore: page.hasMore,
        errorMessage: () => null,
      )),
    );
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    if (state.searchQuery.isEmpty) return;

    emit(state.copyWith(
      searchQuery: () => '',
      status: ProductListStatus.loading,
      products: [],
      skip: 0,
      hasMore: true,
      errorMessage: () => null,
    ));

    _fetchFirstPage();
  }

  Future<void> loadMoreProducts() async {
    if (!state.hasMore || state.isLoadingMore || state.status == ProductListStatus.loading) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final currentSkip = state.products.length;

    final result = state.isSearching
        ? await searchProductsUseCase(
            query: state.searchQuery,
            limit: pageSize,
            skip: currentSkip,
          )
        : (state.selectedCategory != null && state.selectedCategory!.isNotEmpty)
            ? await getProductsByCategoryUseCase(
                categorySlug: state.selectedCategory!,
                limit: pageSize,
                skip: currentSkip,
                sortBy: state.sortOption.sortBy,
                order: state.sortOption.order,
              )
            : await getProductsUseCase(
                limit: pageSize,
                skip: currentSkip,
                sortBy: state.sortOption.sortBy,
                order: state.sortOption.order,
              );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
      )),
      (page) {
        final updatedProducts = List<ProductEntity>.from(state.products)..addAll(page.products);
        emit(state.copyWith(
          isLoadingMore: false,
          products: updatedProducts,
          total: page.total,
          skip: updatedProducts.length,
          hasMore: page.hasMore,
        ));
      },
    );
  }

  Future<void> selectCategory(String? categorySlug) async {
    if (state.selectedCategory == categorySlug && !state.isSearching) return;

    _debounceTimer?.cancel();

    emit(state.copyWith(
      status: ProductListStatus.loading,
      selectedCategory: () => categorySlug,
      searchQuery: () => '',
      products: [],
      hasMore: true,
      skip: 0,
      errorMessage: () => null,
    ));

    await _fetchFirstPage();
  }

  Future<void> setSortOption(ProductSortOption sortOption) async {
    if (state.sortOption == sortOption) return;

    emit(state.copyWith(
      status: ProductListStatus.loading,
      sortOption: sortOption,
      products: [],
      hasMore: true,
      skip: 0,
      errorMessage: () => null,
    ));

    await _fetchFirstPage();
  }

  Future<void> refresh() async {
    _debounceTimer?.cancel();

    emit(state.copyWith(
      status: ProductListStatus.loading,
      skip: 0,
      hasMore: true,
      errorMessage: () => null,
    ));

    if (state.isSearching) {
      await _executeSearch(state.searchQuery);
    } else {
      await Future.wait([
        _fetchCategories(),
        _fetchFirstPage(),
      ]);
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
