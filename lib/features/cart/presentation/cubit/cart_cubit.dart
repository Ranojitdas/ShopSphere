import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartCubit({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartInitial());

  CartEntity get currentCart {
    final state = this.state;
    if (state is CartLoaded) {
      return state.cart;
    }
    return const CartEntity();
  }

  Future<void> loadCart() async {
    emit(const CartLoading());
    final result = await getCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> addToCart(CartItemEntity item) async {
    final result = await addToCartUseCase(item);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart, notificationMessage: '${item.title} added to cart')),
    );
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    final result = await updateCartQuantityUseCase(productId, quantity);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> removeFromCart(int productId) async {
    final result = await removeFromCartUseCase(productId);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart, notificationMessage: 'Item removed from cart')),
    );
  }

  Future<void> clearCart() async {
    final result = await clearCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}
