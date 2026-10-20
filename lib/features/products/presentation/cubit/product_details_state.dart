import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

enum ProductDetailsStatus { initial, loading, success, failure }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final ProductEntity? product;
  final int selectedImageIndex;
  final int quantity;
  final bool isNotFound;
  final String? errorMessage;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.selectedImageIndex = 0,
    this.quantity = 1,
    this.isNotFound = false,
    this.errorMessage,
  });

  bool get isLoading => status == ProductDetailsStatus.loading && product == null;
  bool get isSuccess => status == ProductDetailsStatus.success;
  bool get isFailure => status == ProductDetailsStatus.failure;

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductEntity? Function()? product,
    int? selectedImageIndex,
    int? quantity,
    bool? isNotFound,
    String? Function()? errorMessage,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product != null ? product() : this.product,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      quantity: quantity ?? this.quantity,
      isNotFound: isNotFound ?? this.isNotFound,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        product,
        selectedImageIndex,
        quantity,
        isNotFound,
        errorMessage,
      ];
}
