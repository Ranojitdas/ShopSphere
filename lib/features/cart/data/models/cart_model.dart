import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    super.items = const [],
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      items: itemsList
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CartModel.fromEntity(CartEntity entity) {
    return CartModel(
      items: entity.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map((item) => CartItemModel.fromEntity(item).toJson())
          .toList(),
    };
  }
}
