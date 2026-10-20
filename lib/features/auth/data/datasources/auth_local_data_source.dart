import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  });

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getSavedUser();
  Future<void> clearSession();
  Future<bool> hasValidToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const _accessTokenKey = 'SHOP_SPHERE_ACCESS_TOKEN';
  static const _refreshTokenKey = 'SHOP_SPHERE_REFRESH_TOKEN';
  static const _userKey = 'SHOP_SPHERE_USER_DATA';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    try {
      await secureStorage.write(key: _accessTokenKey, value: accessToken);
      await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(key: _accessTokenKey, value: accessToken);
      await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<UserModel?> getSavedUser() async {
    try {
      final userJson = await secureStorage.read(key: _userKey);
      if (userJson == null || userJson.isEmpty) return null;
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await secureStorage.delete(key: _accessTokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
      await secureStorage.delete(key: _userKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await secureStorage.read(key: _accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
