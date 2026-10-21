import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/models/product_page_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    description: 'Test Description',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 5.0,
    rating: 4.5,
    stock: 10,
    tags: ['beauty'],
    thumbnail: 'https://example.com/thumb.png',
  );

  const tProductPageModel = ProductPageModel(
    products: [tProductModel],
    total: 1,
    skip: 0,
    limit: 20,
  );

  group('getProducts', () {
    test('should return Right(ProductPageEntity) when remote call is successful',
        () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
        ),
      ).thenAnswer((_) async => tProductPageModel);

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result, const Right(tProductPageModel));
      verify(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
        ),
      ).called(1);
    });

    test('should return Left(ServerFailure) when remote call throws ServerException',
        () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
        ),
      ).thenThrow(const ServerException('Server error'));

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result, const Left(ServerFailure('Server error')));
      verify(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
        ),
      ).called(1);
    });

    test('should return Left(NetworkFailure) on Dio connection timeout', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/products'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      when(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
        ),
      ).thenThrow(dioException);

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('getProductById', () {
    test('should return Right(ProductModel) when remote call succeeds', () async {
      when(() => mockRemoteDataSource.getProductById(1))
          .thenAnswer((_) async => tProductModel);

      final result = await repository.getProductById(1);

      expect(result, const Right(tProductModel));
      verify(() => mockRemoteDataSource.getProductById(1)).called(1);
    });

    test('should return Left(NotFoundFailure) on HTTP 404', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/products/9999'),
        response: Response(
          requestOptions: RequestOptions(path: '/products/9999'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockRemoteDataSource.getProductById(9999))
          .thenThrow(dioException);

      final result = await repository.getProductById(9999);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected NotFoundFailure'),
      );
    });
  });
}
