import 'package:dio/dio.dart';
import '../storage/hive_storage.dart';

class CacheInterceptor extends Interceptor {
  // Store responses for 24 hours
  static const Duration _cacheDuration = Duration(hours: 24);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = response.requestOptions.uri.toString();
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': response.data,
      };
      await HiveStorage.userCacheBox.put(cacheKey, cacheData);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.method.toUpperCase() == 'GET' &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout)) {
      final cacheKey = err.requestOptions.uri.toString();
      final cachedJson = HiveStorage.userCacheBox.get(cacheKey);

      if (cachedJson != null) {
        final cacheMap = Map<String, dynamic>.from(cachedJson);
        final timestampStr = cacheMap['timestamp'] as String;
        final timestamp = DateTime.parse(timestampStr);

        // Check if cache is still valid
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          // Serve from cache
          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              statusCode: 200,
              data: cacheMap['data'],
              statusMessage: 'Served from Cache',
            ),
          );
        } else {
          // Cache expired, remove it
          await HiveStorage.userCacheBox.delete(cacheKey);
        }
      }
    }

    return handler.next(err);
  }
}
