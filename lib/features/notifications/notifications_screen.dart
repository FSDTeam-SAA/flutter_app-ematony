import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/mock/app_mock_data.dart';
import '../../core/models/notification_model.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationModel>> fetchMyNotifications() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/notification');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return AppMockData.notifications()
          .map(NotificationModel.fromJson)
          .toList();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.patch('/notification/read-all');
    } catch (_) {}
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class NotificationsController extends ChangeNotifier {
  NotificationsController({required NotificationsRepository repository})
      : _repository = repository;

  final NotificationsRepository _repository;

  bool isLoading = false;
  List<NotificationModel> notifications = [];
  String? error;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
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

// ─── NotificationsScreen ──────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Mark All Read
          AjoPatternHeader(
            height: MediaQuery.of(context).padding.top + 96,
            bottomRadius: 22,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                  ),
                ),
                if (ctrl.unreadCount > 0)
                  TextButton(
                    onPressed: ctrl.markAllRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications yet.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: ctrl.load,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: ctrl.notifications.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final n = ctrl.notifications[index];
                            return _NotificationCard(notification: n);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final isTopUp = notification.isTopUp;
    return AjoCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: notification.isRead ? Colors.white : const Color(0xFFF5FBF7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isTopUp ? AppColors.subtle : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RotatedBox(
              quarterTurns: isTopUp ? 0 : 2,
              child: Icon(
                Icons.north_east_rounded,
                color: isTopUp ? AppColors.primary : AppColors.danger,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                ),
                if (notification.content.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    notification.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  notification.timeAgo,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xFF9BA3AF)),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
