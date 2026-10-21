import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.productId,
    required super.title,
    required super.price,
    required super.discountPercentage,
    required super.quantity,
    required super.stock,
    required super.thumbnail,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      quantity: json['quantity'] as int,
      stock: json['stock'] as int,
      thumbnail: json['thumbnail'] as String,
    );
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      title: entity.title,
      price: entity.price,
      discountPercentage: entity.discountPercentage,
      quantity: entity.quantity,
      stock: entity.stock,
      thumbnail: entity.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'discountPercentage': discountPercentage,
      'quantity': quantity,
      'stock': stock,
      'thumbnail': thumbnail,
    };
  }
}
