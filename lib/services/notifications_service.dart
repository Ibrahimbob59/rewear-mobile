import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final Dio _dio;

  NotificationsService(this._dio);

  /// Get paginated notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    bool? unreadOnly,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };

      if (unreadOnly != null) {
        queryParams['unread_only'] = unreadOnly;
      }

      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      final List<dynamic> notificationsData = response.data['data'] is List
          ? response.data['data']
          : response.data['data']['data'] ?? [];

      final notifications = notificationsData
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'notifications': notifications,
        'meta': response.data['meta'] ?? {},
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent notifications (last 10)
  Future<List<AppNotification>> getRecentNotifications() async {
    try {
      final response = await _dio.get('/notifications/recent');

      final List<dynamic> data = response.data['data'] ?? [];

      return data
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['data']['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.post('/notifications/$notificationId/read');
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/notifications/mark-all-read');
    } catch (e) {
      rethrow;
    }
  }
}
