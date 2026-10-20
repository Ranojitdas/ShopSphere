import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailsCubit({
    required this.getProductDetailsUseCase,
  }) : super(const ProductDetailsState());

  Future<void> loadProductDetails(int id, {ProductEntity? initialProduct}) async {
    if (initialProduct != null) {
      emit(state.copyWith(
        product: () => initialProduct,
        status: ProductDetailsStatus.loading,
        isNotFound: false,
        errorMessage: () => null,
      ));
    } else {
      emit(state.copyWith(
        status: ProductDetailsStatus.loading,
        isNotFound: false,
        errorMessage: () => null,
      ));
    }

    final result = await getProductDetailsUseCase(id);

    if (isClosed) return;

    result.fold(
      (failure) {
        final is404 = failure is NotFoundFailure || failure.message.toLowerCase().contains('not found');
        emit(state.copyWith(
          status: ProductDetailsStatus.failure,
          isNotFound: is404,
          errorMessage: () => failure.message,
        ));
      },
      (product) => emit(state.copyWith(
        status: ProductDetailsStatus.success,
        product: () => product,
        isNotFound: false,
        errorMessage: () => null,
      )),
    );
  }

  void selectImage(int index) {
    if (state.selectedImageIndex == index) return;
    emit(state.copyWith(selectedImageIndex: index));
  }

  void incrementQuantity() {
    final maxStock = state.product?.stock ?? 99;
    if (state.quantity < maxStock) {
      emit(state.copyWith(quantity: state.quantity + 1));
    }
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }
}
