import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({
    this.items = const [],
  });

  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  int get totalUniqueItems => items.length;

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.itemTotal);

  double get totalDiscount =>
      items.fold(0.0, (sum, item) => sum + item.itemDiscountSavings);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.itemDiscountedTotal);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [items];
}
