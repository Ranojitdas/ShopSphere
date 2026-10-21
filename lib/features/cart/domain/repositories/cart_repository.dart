import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';
import '../entities/order_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addToCart(CartItemEntity item);
  Future<Either<Failure, CartEntity>> updateQuantity(int productId, int quantity);
  Future<Either<Failure, CartEntity>> removeFromCart(int productId);
  Future<Either<Failure, CartEntity>> clearCart();
  Future<Either<Failure, OrderEntity>> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  });
}
