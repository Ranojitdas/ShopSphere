import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/product_page_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductPageEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  Future<Either<Failure, ProductEntity>> getProductById(int id);

  Future<Either<Failure, ProductPageEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, ProductPageEntity>> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });
}
