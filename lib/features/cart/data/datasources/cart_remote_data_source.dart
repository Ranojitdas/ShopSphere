import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../models/order_model.dart';

abstract class CartRemoteDataSource {
  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  const CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  }) async {
    try {
      final payload = {
        'userId': userId,
        'products': items
            .map((item) => {
                  'id': item.productId,
                  'quantity': item.quantity,
                })
            .toList(),
      };

      final response = await dio.post(
        '/carts/add',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const ServerException('Failed to place order on server.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException('No internet connection. Please retry.');
      }
      final message = e.response?.data?['message'] ?? 'Failed to place order.';
      throw ServerException(message.toString());
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException('An unexpected error occurred during checkout.');
    }
  }
}
