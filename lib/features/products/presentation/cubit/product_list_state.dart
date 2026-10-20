import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

enum ProductListStatus { initial, loading, success, failure }

enum ProductSortOption {
  defaultSort,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  titleAZ,
}

extension ProductSortOptionX on ProductSortOption {
  String get label {
    switch (this) {
      case ProductSortOption.defaultSort:
        return 'Default';
      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ProductSortOption.ratingHighToLow:
        return 'Highest Rating';
      case ProductSortOption.titleAZ:
        return 'Name: A to Z';
    }
  }

  String? get sortBy {
    switch (this) {
      case ProductSortOption.defaultSort:
        return null;
      case ProductSortOption.priceLowToHigh:
      case ProductSortOption.priceHighToLow:
        return 'price';
      case ProductSortOption.ratingHighToLow:
        return 'rating';
      case ProductSortOption.titleAZ:
        return 'title';
    }
  }

  String? get order {
    switch (this) {
      case ProductSortOption.defaultSort:
        return null;
      case ProductSortOption.priceLowToHigh:
      case ProductSortOption.titleAZ:
        return 'asc';
      case ProductSortOption.priceHighToLow:
      case ProductSortOption.ratingHighToLow:
        return 'desc';
    }
  }
}

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? selectedCategory;
  final ProductSortOption sortOption;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final int total;
  final int skip;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.sortOption = ProductSortOption.defaultSort,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
  });

  bool get isInitialLoading => status == ProductListStatus.loading && products.isEmpty;
  bool get isSuccess => status == ProductListStatus.success;
  bool get isFailure => status == ProductListStatus.failure && products.isEmpty;
  bool get isEmpty => status == ProductListStatus.success && products.isEmpty;

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? Function()? selectedCategory,
    ProductSortOption? sortOption,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? errorMessage,
    int? total,
    int? skip,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      sortOption: sortOption ?? this.sortOption,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        selectedCategory,
        sortOption,
        hasMore,
        isLoadingMore,
        errorMessage,
        total,
        skip,
      ];
}
