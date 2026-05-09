import 'package:flutter/foundation.dart';
import '../../core/models/notification_model.dart';
import 'notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({required NotificationsRepository repository})
      : _repository = repository;

  final NotificationsRepository _repository;

  bool isLoading = false;
  List<NotificationModel> notifications = [];
  String? error;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    if (isLoading) return;
    
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      notifications = await _repository.fetchMyNotifications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    notifications = notifications
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              content: n.content,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ))
        .toList();
    notifyListeners();
  }
}
