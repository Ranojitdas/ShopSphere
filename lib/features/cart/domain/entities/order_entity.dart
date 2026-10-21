import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class OrderEntity extends Equatable {
  final int orderId;
  final int userId;
  final List<CartItemEntity> products;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;
  final DateTime createdAt;

  const OrderEntity({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.totalProducts,
    required this.totalQuantity,
    required this.createdAt,
  });

  double get totalDiscount => total - discountedTotal;

  @override
  List<Object?> get props => [
        orderId,
        userId,
        products,
        total,
        discountedTotal,
        totalProducts,
        totalQuantity,
        createdAt,
      ];
}
