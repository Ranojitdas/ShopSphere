import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_model.dart';

abstract class CartLocalDataSource {
  Future<CartModel> getCart();
  Future<void> saveCart(CartModel cart);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const _cartKey = 'cached_cart';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<CartModel> getCart() async {
    try {
      final jsonString = sharedPreferences.getString(_cartKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        return CartModel.fromJson(decoded);
      }
      return const CartModel(items: []);
    } catch (_) {
      throw const CacheException('Failed to read cached cart data');
    }
  }

  @override
  Future<void> saveCart(CartModel cart) async {
    try {
      final jsonString = jsonEncode(cart.toJson());
      await sharedPreferences.setString(_cartKey, jsonString);
    } catch (_) {
      throw const CacheException('Failed to save cart to local cache');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await sharedPreferences.remove(_cartKey);
    } catch (_) {
      throw const CacheException('Failed to clear cached cart');
    }
  }
}
