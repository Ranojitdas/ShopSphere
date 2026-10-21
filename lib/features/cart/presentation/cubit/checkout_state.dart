import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;

  const CheckoutSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
