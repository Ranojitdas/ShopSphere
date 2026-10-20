import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final AuthLocalDataSource localDataSource;
  final Dio dio;

  AuthInterceptor({
    required this.localDataSource,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localDataSource.getAccessToken();
    if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiEndpoints.login)) {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: ApiEndpoints.connectTimeout,
              receiveTimeout: ApiEndpoints.receiveTimeout,
            ),
          );

          final response = await refreshDio.post(
            ApiEndpoints.refresh,
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 30,
            },
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'] as String? ?? '';
            final newRefreshToken = response.data['refreshToken'] as String? ?? refreshToken;

            await localDataSource.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await localDataSource.clearSession();
        }
      } else {
        await localDataSource.clearSession();
      }
    }
    handler.next(err);
  }
}
