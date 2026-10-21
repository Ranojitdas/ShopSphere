import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product_entity.dart';
import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tProductModel = ProductModel(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    description:
        'The Essence Mascara Lash Princess is a popular mascara known for its volumizing effect.',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 7.17,
    rating: 4.94,
    stock: 5,
    tags: ['beauty', 'mascara'],
    brand: 'Essence',
    sku: 'RCH45Q1A',
    weight: 2.0,
    warrantyInformation: '1 month warranty',
    shippingInformation: 'Ships in 1 month',
    availabilityStatus: 'Low Stock',
    returnPolicy: '30 days return policy',
    minimumOrderQuantity: 24,
    images: [
      'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png'
    ],
    thumbnail:
        'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
  );

  test('should be a subclass of ProductEntity', () {
    expect(tProductModel, isA<ProductEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when parsing full fixture JSON', () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('product_fixture.json')) as Map<String, dynamic>;

      final result = ProductModel.fromJson(jsonMap);

      expect(result.id, 1);
      expect(result.title, 'Essence Mascara Lash Princess');
      expect(result.price, 9.99);
      expect(result.stock, 5);
      expect(result.reviews.length, 1);
      expect(result.reviews.first.reviewerName, 'John Doe');
    });

    test('should calculate discountedPrice accurately', () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('product_fixture.json')) as Map<String, dynamic>;

      final result = ProductModel.fromJson(jsonMap);

      // 9.99 * (1 - 7.17/100) = 9.99 * 0.9283 = 9.2737...
      expect(result.discountedPrice, closeTo(9.27, 0.01));
    });

    test('should handle null brand and missing optional fields safely', () {
      final jsonMap = {
        'id': 2,
        'title': 'Generic Item',
        'price': 10.0,
        'stock': 0,
      };

      final result = ProductModel.fromJson(jsonMap);

      expect(result.id, 2);
      expect(result.title, 'Generic Item');
      expect(result.brand, isNull);
      expect(result.reviews, isEmpty);
      expect(result.isOutOfStock, isTrue);
    });
  });
}
