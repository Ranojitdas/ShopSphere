import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await localDataSource.getCart();
      return Right(cart);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure('Unexpected error reading cart cache'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(CartItemEntity item) async {
    try {
      final currentCart = await localDataSource.getCart();
      final items = List<CartItemEntity>.from(currentCart.items);
      final index = items.indexWhere((element) => element.productId == item.productId);

      if (index >= 0) {
        final existingItem = items[index];
        final newQuantity = (existingItem.quantity + item.quantity).clamp(1, item.stock);
        items[index] = existingItem.copyWith(quantity: newQuantity);
      } else {
        final clampedQuantity = item.quantity.clamp(1, item.stock);
        items.add(item.copyWith(quantity: clampedQuantity));
      }

      final updatedCart = CartModel(items: items);
      await localDataSource.saveCart(updatedCart);
      return Right(updatedCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure('Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity(
    int productId,
    int quantity,
  ) async {
    try {
      final currentCart = await localDataSource.getCart();
      final items = List<CartItemEntity>.from(currentCart.items);
      final index = items.indexWhere((element) => element.productId == productId);

      if (index >= 0) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          final existingItem = items[index];
          final clampedQuantity = quantity.clamp(1, existingItem.stock);
          items[index] = existingItem.copyWith(quantity: clampedQuantity);
        }
      }

      final updatedCart = CartModel(items: items);
      await localDataSource.saveCart(updatedCart);
      return Right(updatedCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure('Failed to update cart quantity'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(int productId) async {
    try {
      final currentCart = await localDataSource.getCart();
      final items = currentCart.items
          .where((element) => element.productId != productId)
          .toList();

      final updatedCart = CartModel(items: items);
      await localDataSource.saveCart(updatedCart);
      return Right(updatedCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure('Failed to remove item from cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(CartEntity(items: []));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure('Failed to clear cart'));
    }
  }
}
