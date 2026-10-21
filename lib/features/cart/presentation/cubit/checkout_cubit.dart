import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/place_order_usecase.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;

  CheckoutCubit({required this.placeOrderUseCase})
      : super(const CheckoutInitial());

  Future<void> submitOrder({
    required int userId,
    required List<CartItemEntity> items,
  }) async {
    emit(const CheckoutSubmitting());
    final result = await placeOrderUseCase(
      userId: userId,
      items: items,
    );
    result.fold(
      (failure) => emit(CheckoutFailure(failure.message)),
      (order) => emit(CheckoutSuccess(order)),
    );
  }

  void reset() {
    emit(const CheckoutInitial());
  }
}
