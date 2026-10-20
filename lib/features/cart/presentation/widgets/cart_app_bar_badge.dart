import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartAppBarBadge extends StatelessWidget {
  const CartAppBarBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) {
        final prevCount = previous is CartLoaded ? previous.cart.totalItemCount : 0;
        final currCount = current is CartLoaded ? current.cart.totalItemCount : 0;
        return prevCount != currCount;
      },
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.cart.totalItemCount : 0;

        return IconButton(
          tooltip: 'Shopping Cart',
          icon: Badge(
            isLabelVisible: itemCount > 0,
            label: Text(
              itemCount > 99 ? '99+' : '$itemCount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        );
      },
    );
  }
}
