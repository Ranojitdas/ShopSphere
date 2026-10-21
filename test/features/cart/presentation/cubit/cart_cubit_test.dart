import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_entity.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item_entity.dart';
import 'package:shopsphere/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_state.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

class MockUpdateCartQuantityUseCase extends Mock
    implements UpdateCartQuantityUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late CartCubit cartCubit;
  late MockGetCartUseCase mockGetCartUseCase;
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockUpdateCartQuantityUseCase mockUpdateCartQuantityUseCase;
  late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
  late MockClearCartUseCase mockClearCartUseCase;

  const tItem = CartItemEntity(
    productId: 1,
    title: 'Lipstick',
    price: 12.99,
    discountPercentage: 0.0,
    quantity: 1,
    stock: 5,
    thumbnail: 'https://example.com/lip.png',
  );

  const tCart = CartEntity(items: [tItem]);

  setUp(() {
    mockGetCartUseCase = MockGetCartUseCase();
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockUpdateCartQuantityUseCase = MockUpdateCartQuantityUseCase();
    mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
    mockClearCartUseCase = MockClearCartUseCase();

    cartCubit = CartCubit(
      getCartUseCase: mockGetCartUseCase,
      addToCartUseCase: mockAddToCartUseCase,
      updateCartQuantityUseCase: mockUpdateCartQuantityUseCase,
      removeFromCartUseCase: mockRemoveFromCartUseCase,
      clearCartUseCase: mockClearCartUseCase,
    );
  });

  tearDown(() {
    cartCubit.close();
  });

  test('initial state should be CartInitial', () {
    expect(cartCubit.state, const CartInitial());
  });

  blocTest<CartCubit, CartState>(
    'loadCart emits [CartLoading, CartLoaded] on success',
    build: () {
      when(() => mockGetCartUseCase())
          .thenAnswer((_) async => const Right(tCart));
      return cartCubit;
    },
    act: (cubit) => cubit.loadCart(),
    expect: () => [
      const CartLoading(),
      const CartLoaded(tCart),
    ],
  );

  blocTest<CartCubit, CartState>(
    'loadCart emits [CartLoading, CartError] on failure',
    build: () {
      when(() => mockGetCartUseCase())
          .thenAnswer((_) async => const Left(CacheFailure('Cache read error')));
      return cartCubit;
    },
    act: (cubit) => cubit.loadCart(),
    expect: () => [
      const CartLoading(),
      const CartError('Cache read error'),
    ],
  );

  blocTest<CartCubit, CartState>(
    'addToCart emits [CartLoaded] with confirmation notification message',
    build: () {
      when(() => mockAddToCartUseCase(tItem))
          .thenAnswer((_) async => const Right(tCart));
      return cartCubit;
    },
    act: (cubit) => cubit.addToCart(tItem),
    expect: () => [
      const CartLoaded(tCart, notificationMessage: 'Lipstick added to cart'),
    ],
  );

  blocTest<CartCubit, CartState>(
    'updateQuantity with quantity <= 0 routes to removeFromCart',
    build: () {
      const emptyCart = CartEntity(items: []);
      when(() => mockRemoveFromCartUseCase(1))
          .thenAnswer((_) async => const Right(emptyCart));
      return cartCubit;
    },
    act: (cubit) => cubit.updateQuantity(1, 0),
    expect: () => [
      const CartLoaded(CartEntity(items: []), notificationMessage: 'Item removed from cart'),
    ],
    verify: (_) {
      verify(() => mockRemoveFromCartUseCase(1)).called(1);
      verifyNever(() => mockUpdateCartQuantityUseCase(any(), any()));
    },
  );

  blocTest<CartCubit, CartState>(
    'clearCart emits [CartLoaded] with empty cart',
    build: () {
      const emptyCart = CartEntity(items: []);
      when(() => mockClearCartUseCase())
          .thenAnswer((_) async => const Right(emptyCart));
      return cartCubit;
    },
    act: (cubit) => cubit.clearCart(),
    expect: () => [
      const CartLoaded(CartEntity(items: [])),
    ],
  );
}
