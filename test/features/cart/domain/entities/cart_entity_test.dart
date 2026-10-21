import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_entity.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  const item1 = CartItemEntity(
    productId: 101,
    title: 'Wireless Earbuds',
    price: 100.0,
    discountPercentage: 20.0,
    quantity: 2,
    stock: 5,
    thumbnail: 'https://example.com/earbuds.png',
  );

  const item2 = CartItemEntity(
    productId: 102,
    title: 'Phone Case',
    price: 50.0,
    discountPercentage: 10.0,
    quantity: 1,
    stock: 10,
    thumbnail: 'https://example.com/case.png',
  );

  group('CartItemEntity calculations & defense-in-depth', () {
    test('should calculate unitDiscountedPrice and itemTotals correctly', () {
      // 100 * (1 - 0.20) = 80.0
      expect(item1.unitDiscountedPrice, 80.0);
      expect(item1.itemTotal, 200.0);
      expect(item1.itemDiscountedTotal, 160.0);
      expect(item1.itemDiscountSavings, 40.0);
    });

    test('should correctly report canDecrement and canIncrement', () {
      expect(item1.canDecrement, isTrue); // quantity 2 > 1
      expect(item1.canIncrement, isTrue); // quantity 2 < stock 5

      expect(item2.canDecrement, isFalse); // quantity 1 is at minimum
      expect(item2.canIncrement, isTrue);
    });

    test('copyWith should clamp quantity to never fall below 1', () {
      final clampedItem = item1.copyWith(quantity: -3);
      expect(clampedItem.quantity, 1);
    });

    test('copyWith should clamp quantity to never exceed available stock', () {
      final clampedItem = item1.copyWith(quantity: 99);
      expect(clampedItem.quantity, item1.stock);
    });
  });

  group('CartEntity aggregate calculations', () {
    const cart = CartEntity(items: [item1, item2]);

    test('should calculate subtotal, totalDiscount, and totalPrice accurately', () {
      // item1: 100 * 2 = 200, item2: 50 * 1 = 50 -> subtotal = 250
      expect(cart.subtotal, 250.0);

      // item1 discounted total: 80 * 2 = 160
      // item2 discounted total: 45 * 1 = 45
      // totalPrice = 205.0
      expect(cart.totalPrice, 205.0);

      // totalDiscount = 250 - 205 = 45.0
      expect(cart.totalDiscount, 45.0);
      expect(cart.totalItemCount, 3);
      expect(cart.isNotEmpty, isTrue);
    });

    test('empty cart should return zeroes and isNotEmpty = false', () {
      const emptyCart = CartEntity(items: []);
      expect(emptyCart.subtotal, 0.0);
      expect(emptyCart.totalPrice, 0.0);
      expect(emptyCart.totalItemCount, 0);
      expect(emptyCart.isEmpty, isTrue);
    });
  });
}
