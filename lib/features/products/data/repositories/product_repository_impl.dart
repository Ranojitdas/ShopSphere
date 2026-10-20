import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_page_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProductPageEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    try {
      final result = await remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        sortBy: sortBy,
        order: order,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      final result = await remoteDataSource.getProductById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductPageEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductPageEntity>> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    try {
      final result = await remoteDataSource.getProductsByCategory(
        categorySlug: categorySlug,
        limit: limit,
        skip: skip,
        sortBy: sortBy,
        order: order,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
