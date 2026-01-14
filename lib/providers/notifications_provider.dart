import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service;

  NotificationsProvider(this._service);

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;

  /// Load notifications (paginated)
  Future<void> loadNotifications({bool refresh = false, bool unreadOnly = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getNotifications(
        page: _currentPage,
        unreadOnly: unreadOnly,
      );

      final newNotifications = result['notifications'] as List<AppNotification>;
      final meta = result['meta'] as Map<String, dynamic>;

      if (refresh) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      _currentPage++;
      _lastPage = meta['current_page'] ?? 1;
      _hasMore = _currentPage <= _lastPage;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load recent notifications (last 10)
  Future<void> loadRecentNotifications() async {
    try {
      _notifications = await _service.getRecentNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Silently fail for count
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          data: _notifications[index].data,
        );
      }

      if (_unreadCount > 0) {
        _unreadCount--;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();

      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        data: n.data,
      )).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refresh notifications and unread count
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadUnreadCount(),
    ]);
  }
}
