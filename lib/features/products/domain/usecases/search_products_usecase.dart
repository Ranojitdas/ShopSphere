import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_page_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<Failure, ProductPageEntity>> call({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    return repository.searchProducts(
      query: query,
      limit: limit,
      skip: skip,
    );
  }
}
