import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/cart_repository.dart';

class PlaceOrderUseCase {
  final CartRepository repository;

  const PlaceOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required int userId,
    required List<CartItemEntity> items,
  }) {
    return repository.placeOrder(
      userId: userId,
      items: items,
    );
  }
}
