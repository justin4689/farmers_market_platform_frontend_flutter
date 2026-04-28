import '../../core/constants/app_strings.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  factory ApiException.fromStatusCode(int statusCode, [String? serverMessage]) {
    final message = switch (statusCode) {
      400 => serverMessage ?? AppStrings.validationError,
      401 => AppStrings.sessionExpired,
      403 => AppStrings.forbidden,
      422 => serverMessage ?? AppStrings.validationError,
      500 => AppStrings.serverError,
      _ => serverMessage ?? AppStrings.unknownError,
    };
    return ApiException(statusCode: statusCode, message: message);
  }

  factory ApiException.network() => const ApiException(
        statusCode: 0,
        message: AppStrings.networkError,
      );

  @override
  String toString() => 'ApiException($statusCode): $message';
}
