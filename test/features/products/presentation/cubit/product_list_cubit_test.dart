import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/category_entity.dart';
import 'package:shopsphere/features/products/domain/entities/product_entity.dart';
import 'package:shopsphere/features/products/domain/entities/product_page_entity.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_list_cubit.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_list_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

void main() {
  late ProductListCubit cubit;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;
  late MockSearchProductsUseCase mockSearchProductsUseCase;

  const tProduct = ProductEntity(
    id: 1,
    title: 'Essence Mascara',
    description: 'Great mascara',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 0.0,
    rating: 4.8,
    stock: 5,
    tags: ['beauty'],
    thumbnail: 'https://example.com/mascara.png',
  );

  const tProductPage = ProductPageEntity(
    products: [tProduct],
    total: 1,
    skip: 0,
    limit: 20,
  );

  const tCategory = CategoryEntity(
    slug: 'beauty',
    name: 'Beauty',
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();
    mockSearchProductsUseCase = MockSearchProductsUseCase();

    cubit = ProductListCubit(
      getProductsUseCase: mockGetProductsUseCase,
      getCategoriesUseCase: mockGetCategoriesUseCase,
      getProductsByCategoryUseCase: mockGetProductsByCategoryUseCase,
      searchProductsUseCase: mockSearchProductsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be ProductListState default', () {
    expect(cubit.state, const ProductListState());
    expect(cubit.state.status, ProductListStatus.initial);
  });

  blocTest<ProductListCubit, ProductListState>(
    'loadInitialCatalog emits loading, then categories and product list on success',
    build: () {
      when(() => mockGetCategoriesUseCase())
          .thenAnswer((_) async => const Right([tCategory]));
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenAnswer((_) async => const Right(tProductPage));
      return cubit;
    },
    act: (cubit) => cubit.loadInitialCatalog(),
    expect: () => [
      const ProductListState(status: ProductListStatus.loading),
      const ProductListState(
        status: ProductListStatus.loading,
        categories: [tCategory],
      ),
      const ProductListState(
        status: ProductListStatus.success,
        categories: [tCategory],
        products: [tProduct],
        total: 1,
        skip: 1,
        hasMore: false,
      ),
    ],
  );

  blocTest<ProductListCubit, ProductListState>(
    'loadInitialCatalog emits failure state when product fetch fails',
    build: () {
      when(() => mockGetCategoriesUseCase())
          .thenAnswer((_) async => const Right([]));
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('API unavailable')));
      return cubit;
    },
    act: (cubit) => cubit.loadInitialCatalog(),
    expect: () => [
      const ProductListState(status: ProductListStatus.loading),
      const ProductListState(
        status: ProductListStatus.failure,
        errorMessage: 'API unavailable',
      ),
    ],
  );

  blocTest<ProductListCubit, ProductListState>(
    'selectCategory updates selectedCategory and triggers filtered fetch',
    build: () {
      when(
        () => mockGetProductsByCategoryUseCase(
          categorySlug: 'beauty',
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenAnswer((_) async => const Right(tProductPage));
      return cubit;
    },
    act: (cubit) => cubit.selectCategory('beauty'),
    expect: () => [
      const ProductListState(
        status: ProductListStatus.loading,
        selectedCategory: 'beauty',
        products: [],
        skip: 0,
        hasMore: true,
      ),
      const ProductListState(
        status: ProductListStatus.success,
        selectedCategory: 'beauty',
        products: [tProduct],
        total: 1,
        skip: 1,
        hasMore: false,
      ),
    ],
  );
}
