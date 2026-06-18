class AppException implements Exception {

  final String message;

  final String errorCode;

  AppException({
    required this.message,
    required this.errorCode,
  });

  @override
  String toString() {
    return message;
  }
}