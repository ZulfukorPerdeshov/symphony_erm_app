import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static late Dio _dio;
  static String? _currentAccessToken;

  static void init() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeoutMs),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      requestHeader: kDebugMode,
      responseHeader: false,
      error: kDebugMode,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authorization header if token exists
        if (_currentAccessToken != null) {
          options.headers['Authorization'] = 'Bearer $_currentAccessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final response = await _retry(error.requestOptions);
            handler.resolve(response);
            return;
          } else {
            // Refresh failed, redirect to login
            await _clearTokens();
          }
        }
        handler.next(error);
      },
    ));
  }

  static Future<void> setAccessToken(String? token) async {
    _currentAccessToken = token;
    if (token != null) {
      await StorageService.storeSecure(AppConstants.accessTokenKey, token);
    } else {
      await StorageService.deleteSecure(AppConstants.accessTokenKey);
    }
  }

  static Future<void> loadStoredToken() async {
    _currentAccessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getSecure(AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '${ApiConstants.identityServiceBaseUrl}${ApiConstants.refreshTokenEndpoint}',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't include expired token
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await setAccessToken(newAccessToken);
        await StorageService.storeSecure(AppConstants.refreshTokenKey, newRefreshToken);

        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return false;
  }

  static Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static Future<void> _clearTokens() async {
    _currentAccessToken = null;
    await StorageService.deleteSecure(AppConstants.accessTokenKey);
    await StorageService.deleteSecure(AppConstants.refreshTokenKey);
  }

  // Generic HTTP methods
  static Future<T> get<T>(
    String baseUrl,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static Future<T> post<T>(
    String baseUrl,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static Future<T> put<T>(
    String baseUrl,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        '$baseUrl$endpoint',
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static Future<T> delete<T>(
    String baseUrl,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static Future<T> patch<T>(
    String baseUrl,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        '$baseUrl$endpoint',
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static Future<T> postMultipart<T>(
    String baseUrl,
    String endpoint, {
    required FormData formData,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  static T _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (fromJson != null) {
        return fromJson(response.data);
      } else {
        return response.data as T;
      }
    } else {
      throw ApiException(
        message: 'Unexpected status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  static ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: null,
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final response = e.response;
        String message = 'An error occurred';
        String? errorCode;

        if (response?.data != null) {
          if (response!.data is Map<String, dynamic>) {
            final errorData = response.data as Map<String, dynamic>;
            if (errorData.containsKey('error')) {
              final error = errorData['error'];
              if (error is Map<String, dynamic>) {
                message = error['message'] ?? message;
                errorCode = error['code'];
              } else if (error is String) {
                message = error;
              }
            } else if (errorData.containsKey('message')) {
              message = errorData['message'];
            }
          } else if (response.data is String) {
            message = response.data;
          }
        }

        return ApiException(
          message: message,
          statusCode: response?.statusCode,
          code: errorCode,
          details: response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network settings.',
          code: 'NO_INTERNET',
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificate verification failed',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: e.message ?? 'An unknown error occurred',
          code: 'UNKNOWN',
        );
    }
  }

  // Utility methods
  static void cancelRequests() {
    _dio.close();
  }

  static bool get hasValidToken => _currentAccessToken != null;

  static Future<void> logout() async {
    await _clearTokens();
  }
}