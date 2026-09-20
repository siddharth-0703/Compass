import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../network/models/sync_task.dart';
import '../storage/hive_storage.dart';

class OfflineInterceptor extends Interceptor {
  final _uuid = const Uuid();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If it is a connection error and it's a mutation, queue it
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      final method = err.requestOptions.method.toUpperCase();
      final path = err.requestOptions.path;
      if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(method) && !path.contains('/auth/')) {
        // Generate an Idempotency Key if one wasn't provided
        final idempotencyKey =
            err.requestOptions.headers['X-Idempotency-Key'] ?? _uuid.v4();

        final task = SyncTask(
          id: _uuid.v4(),
          idempotencyKey: idempotencyKey,
          method: method,
          path: err.requestOptions.path,
          headers: err.requestOptions.headers.cast<String, dynamic>(),
          data: err.requestOptions.data is Map
              ? err.requestOptions.data
              : {}, // simplify for MVP
          createdAt: DateTime.now(),
        );

        // Save to Hive
        await HiveStorage.syncQueueBox.put(task.id, task.toJson());

        // Return a synthetic HTTP 202 Accepted response so the UI can update optimistically
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 202,
            data: {
              'success': true,
              'message': 'Queued for offline synchronization',
            },
            statusMessage: 'Offline Queued',
          ),
        );
      }
    }

    // Otherwise just pass the error along
    return handler.next(err);
  }
}
