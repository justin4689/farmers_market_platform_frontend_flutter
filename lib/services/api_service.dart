import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_urls.dart';
import '../core/exceptions/api_exception.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  ApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        final response = error.response;
        if (response == null) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException.network(),
            ),
          );
        }

        String? serverMessage;
        final data = response.data;
        if (data is Map) {
          serverMessage = data['message']?.toString() ??
              data['error']?.toString();
        }

        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: response,
            error: ApiException.fromStatusCode(
              response.statusCode ?? 0,
              serverMessage,
            ),
          ),
        );
      },
    ));
  }

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  ApiException _handleDioError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException.network();
  }

  ApiException handleError(Object error) {
    if (error is DioException) return _handleDioError(error);
    if (error is ApiException) return error;
    return ApiException.network();
  }
}
