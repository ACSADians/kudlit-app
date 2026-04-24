class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;
}

class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;
}
