import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.userId,
    required super.products,
    required super.total,
    required super.discountedTotal,
    required super.totalProducts,
    required super.totalQuantity,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    final products = rawProducts.map((p) {
      final map = p as Map<String, dynamic>;
      return CartItemEntity(
        productId: map['id'] as int? ?? 0,
        title: map['title'] as String? ?? 'Product',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        discountPercentage:
            (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
        quantity: map['quantity'] as int? ?? 1,
        stock: 99,
        thumbnail: map['thumbnail'] as String? ?? '',
      );
    }).toList();

    return OrderModel(
      orderId: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      userId: json['userId'] as int? ?? 1,
      products: products,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      totalProducts: json['totalProducts'] as int? ?? products.length,
      totalQuantity: json['totalQuantity'] as int? ??
          products.fold(0, (sum, item) => sum + item.quantity),
      createdAt: DateTime.now(),
    );
  }
}
