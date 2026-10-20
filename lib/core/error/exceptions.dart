class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'An unexpected server error occurred.']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found.']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache failure.']);
}
