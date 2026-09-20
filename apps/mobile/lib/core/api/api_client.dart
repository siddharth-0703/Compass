import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'offline_interceptor.dart';
import 'cache_interceptor.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _refreshQueue = [];

  ApiClient(this._secureStorage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: const String.fromEnvironment(
              'API_URL',
              defaultValue: 'http://10.0.2.2:4000/api/v1',
            ),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle token refresh
            return _handleTokenRefresh(e, handler);
          }
          return handler.next(e);
        },
      ),
    );
    // Add Offline and Cache interceptors
    _dio.interceptors.add(CacheInterceptor());
    _dio.interceptors.add(OfflineInterceptor());
  }

  Dio get dio => _dio;

  Future<void> _handleTokenRefresh(
      DioException e, ErrorInterceptorHandler handler,) async {
    if (e.requestOptions.path.contains('/auth/refresh')) {
      // Refresh token itself expired
      await _secureStorage.clearTokens();
      // TODO: Navigate to login
      return handler.next(e);
    }

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) throw Exception('No refresh token');

        // Note: For Next.js BFF we used cookies, but for Mobile we use Bearer tokens
        // Ensure backend accepts Bearer token or adapt accordingly
        final response = await _dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'] ?? refreshToken;

        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        _isRefreshing = false;

        // Replay queued requests
        for (var req in _refreshQueue) {
          final options = req['options'] as RequestOptions;
          final reqHandler = req['handler'] as ErrorInterceptorHandler;
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          _dio.fetch(options).then(
                (res) => reqHandler.resolve(res),
                onError: (err) => reqHandler.reject(err),
              );
        }
        _refreshQueue.clear();

        // Replay current request
        e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final cloneReq = await _dio.fetch(e.requestOptions);
        return handler.resolve(cloneReq);
      } catch (error) {
        _isRefreshing = false;
        _refreshQueue.clear();
        await _secureStorage.clearTokens();
        // TODO: Navigate to login
        return handler.next(e);
      }
    } else {
      // Add to queue
      _refreshQueue.add({'options': e.requestOptions, 'handler': handler});
    }
  }
}
