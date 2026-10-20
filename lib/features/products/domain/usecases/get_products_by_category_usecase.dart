import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_page_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<Either<Failure, ProductPageEntity>> call({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) {
    return repository.getProductsByCategory(
      categorySlug: categorySlug,
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }
}
