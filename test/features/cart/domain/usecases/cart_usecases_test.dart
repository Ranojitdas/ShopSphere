import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_entity.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item_entity.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/update_cart_quantity_usecase.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockCartRepository;
  late AddToCartUseCase addToCartUseCase;
  late UpdateCartQuantityUseCase updateCartQuantityUseCase;
  late RemoveFromCartUseCase removeFromCartUseCase;

  setUp(() {
    mockCartRepository = MockCartRepository();
    addToCartUseCase = AddToCartUseCase(mockCartRepository);
    updateCartQuantityUseCase = UpdateCartQuantityUseCase(mockCartRepository);
    removeFromCartUseCase = RemoveFromCartUseCase(mockCartRepository);
  });

  const tItem = CartItemEntity(
    productId: 1,
    title: 'Product 1',
    price: 15.0,
    discountPercentage: 0.0,
    quantity: 1,
    stock: 5,
    thumbnail: 'https://example.com/thumb.png',
  );

  const tCart = CartEntity(items: [tItem]);

  group('AddToCartUseCase', () {
    test('should return updated CartEntity when adding item to cart', () async {
      when(() => mockCartRepository.addToCart(tItem))
          .thenAnswer((_) async => const Right(tCart));

      final result = await addToCartUseCase(tItem);

      expect(result, const Right(tCart));
      verify(() => mockCartRepository.addToCart(tItem)).called(1);
    });
  });

  group('UpdateCartQuantityUseCase', () {
    test('should call updateQuantity on repository', () async {
      when(() => mockCartRepository.updateQuantity(1, 3))
          .thenAnswer((_) async => const Right(tCart));

      final result = await updateCartQuantityUseCase(1, 3);

      expect(result, const Right(tCart));
      verify(() => mockCartRepository.updateQuantity(1, 3)).called(1);
    });
  });

  group('RemoveFromCartUseCase', () {
    test('should call removeFromCart on repository', () async {
      const emptyCart = CartEntity(items: []);
      when(() => mockCartRepository.removeFromCart(1))
          .thenAnswer((_) async => const Right(emptyCart));

      final result = await removeFromCartUseCase(1);

      expect(result, const Right(emptyCart));
      verify(() => mockCartRepository.removeFromCart(1)).called(1);
    });

    test('should return CacheFailure when repository fails', () async {
      const tFailure = CacheFailure('Storage error');
      when(() => mockCartRepository.removeFromCart(1))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await removeFromCartUseCase(1);

      expect(result, const Left(tFailure));
    });
  });
}
