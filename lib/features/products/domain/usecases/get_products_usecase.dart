import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_page_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, ProductPageEntity>> call({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) {
    return repository.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }
}
