class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  const NetworkException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  final String? code;

  const ValidationException(this.message, {this.code});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => message;
}