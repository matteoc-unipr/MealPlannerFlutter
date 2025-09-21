import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpClient {
  HttpClient({
    Dio? dio,
    int maxAttempts = 3,
    Duration retryBaseDelay = const Duration(milliseconds: 300),
    bool? enableLogging,
  })  : _dio = dio ?? Dio(),
        _maxAttempts = maxAttempts,
        _retryBaseDelay = retryBaseDelay,
        _enableLogging = enableLogging ?? kDebugMode;

  final Dio _dio;
  final int _maxAttempts;
  final Duration _retryBaseDelay;
  final bool _enableLogging;

  Dio get dio => _dio;

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
}
