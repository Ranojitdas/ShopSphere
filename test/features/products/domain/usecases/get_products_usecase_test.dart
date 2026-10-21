import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/product_entity.dart';
import 'package:shopsphere/features/products/domain/entities/product_page_entity.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockProductRepository);
  });

  const tProduct = ProductEntity(
    id: 1,
    title: 'Test Product',
    description: 'Test Description',
    category: 'beauty',
    price: 19.99,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 10,
    tags: ['beauty'],
    thumbnail: 'https://example.com/thumb.png',
  );

  const tProductPage = ProductPageEntity(
    products: [tProduct],
    total: 1,
    skip: 0,
    limit: 20,
  );

  test('should return ProductPageEntity when repository returns products', () async {
    when(
      () => mockProductRepository.getProducts(
        limit: 20,
        skip: 0,
        sortBy: null,
        order: null,
      ),
    ).thenAnswer((_) async => const Right(tProductPage));

    final result = await useCase(limit: 20, skip: 0);

    expect(result, const Right(tProductPage));
    verify(
      () => mockProductRepository.getProducts(
        limit: 20,
        skip: 0,
        sortBy: null,
        order: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockProductRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    const tFailure = ServerFailure('Internal server error');
    when(
      () => mockProductRepository.getProducts(
        limit: 20,
        skip: 0,
        sortBy: null,
        order: null,
      ),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(limit: 20, skip: 0);

    expect(result, const Left(tFailure));
    verify(
      () => mockProductRepository.getProducts(
        limit: 20,
        skip: 0,
        sortBy: null,
        order: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockProductRepository);
  });
}
