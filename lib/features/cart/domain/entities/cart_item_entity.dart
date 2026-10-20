import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String title;
  final double price;
  final double discountPercentage;
  final int quantity;
  final int stock;
  final String thumbnail;

  const CartItemEntity({
    required this.productId,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.quantity,
    required this.stock,
    required this.thumbnail,
  });

  double get unitDiscountedPrice =>
      price * (1 - (discountPercentage / 100));

  double get itemTotal => price * quantity;

  double get itemDiscountedTotal => unitDiscountedPrice * quantity;

  double get itemDiscountSavings => itemTotal - itemDiscountedTotal;

  CartItemEntity copyWith({
    int? productId,
    String? title,
    double? price,
    double? discountPercentage,
    int? quantity,
    int? stock,
    String? thumbnail,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        title,
        price,
        discountPercentage,
        quantity,
        stock,
        thumbnail,
      ];
}
