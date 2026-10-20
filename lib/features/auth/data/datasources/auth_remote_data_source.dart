import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getCurrentUser(String token);

  Future<AuthResponseModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': 30,
      },
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await dio.get(
      ApiEndpoints.me,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await dio.post(
      ApiEndpoints.refresh,
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': 30,
      },
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
