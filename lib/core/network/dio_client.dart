import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/failures.dart';
import 'api_endpoints.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  return dio;
}

Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure('Unable to connect. Please check your internet connection.');

    case DioExceptionType.badResponse:
      final statusCode = exception.response?.statusCode;
      final responseData = exception.response?.data;
      final serverMessage = responseData is Map ? responseData['message']?.toString() : null;

      if (statusCode == 400) {
        return AuthFailure(serverMessage ?? 'Invalid credentials.');
      }
      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure(serverMessage ?? 'Session expired. Please sign in again.');
      }
      if (statusCode == 404) {
        return NotFoundFailure(serverMessage ?? 'Requested item was not found.');
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerFailure(serverMessage ?? 'Server error. Please try again later.');
      }
      return ServerFailure(serverMessage ?? 'Request failed with status $statusCode.');

    case DioExceptionType.cancel:
      return const ServerFailure('Request was cancelled.');

    default:
      return const ServerFailure('An unexpected error occurred. Please try again.');
  }
}
