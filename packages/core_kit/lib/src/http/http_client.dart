import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClient {
  HttpClient({
    Dio? dio,
    int maxAttempts = 3,
    Duration retryBaseDelay = const Duration(milliseconds: 300),
    bool? enableLogging,
    Map<String, String>? apiKeys,
  })  : _dio = dio ?? Dio(),
        _maxAttempts = maxAttempts,
        _retryBaseDelay = retryBaseDelay,
        _enableLogging = enableLogging ?? kDebugMode,
        _apiKeys = {
          ..._readEnvApiKeys(),
          if (apiKeys != null) ...apiKeys,
        };

  final Dio _dio;
  final int _maxAttempts;
  final Duration _retryBaseDelay;
  final bool _enableLogging;
  final Map<String, String> _apiKeys;

  Dio get dio => _dio;
  Map<String, String> get apiKeys => Map.unmodifiable(_apiKeys);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _runWithRetry<T>(() {
      _log('HTTP $method $path');
      return _dio.request<T>(
        path,
        data: data,
        options: (options ?? Options()).copyWith(method: method),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
    });
  }

  Future<Response<T>> _runWithRetry<T>(
    Future<Response<T>> Function() request,
  ) async {
    DioException? lastError;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final response = await request();
        _log(
          'Response ${response.requestOptions.method} '
          '${response.requestOptions.uri} => ${response.statusCode}',
        );
        return response;
      } on DioException catch (error) {
        lastError = error;
        final shouldRetry = _shouldRetry(error) && attempt + 1 < _maxAttempts;
        _log('Request error: ${error.message} (retry: $shouldRetry)');
        if (!shouldRetry) {
          rethrow;
        }

        final backoff = _retryBaseDelay * (1 << attempt);
        _log('Waiting ${backoff.inMilliseconds}ms before retry');
        await Future<void>.delayed(backoff);
      }
    }
    throw lastError!;
  }

  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
        return false;
    }
  }

  void _log(String message) {
    if (!_enableLogging) {
      return;
    }
    log(message, name: 'HttpClient');
  }

  String? apiKey(String name) => _apiKeys[name];

  static Map<String, String> _readEnvApiKeys() {
    if (!dotenv.isInitialized) {
      return const {};
    }

    final map = <String, String>{};
    for (final key in _supportedEnvApiKeys) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        map[key] = value;
      }
    }
    return map;
  }

  static const _supportedEnvApiKeys = <String>{
    'OFF_API_KEY',
    'FDC_API_KEY',
    'EDAMAM_API_KEY',
  };
}
