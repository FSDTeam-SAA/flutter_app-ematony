class NotificationModel {
  final String id;
  final String title;
  final String content;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.content = '',
    this.type,
    this.isRead = false,
    required this.createdAt,
  });

  bool get isTopUp =>
      title.toLowerCase().contains('top up') ||
      title.toLowerCase().contains('topup') ||
      type == 'wallet_topup';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Just Now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt']?.toString() ?? '';
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['message'] ?? '').toString(),
      content: (json['content'] ?? json['body'] ?? '').toString(),
      type: json['type']?.toString(),
      isRead: json['isRead'] == true || json['read'] == true,
      createdAt:
          createdAtRaw.isNotEmpty ? DateTime.tryParse(createdAtRaw) ?? DateTime.now() : DateTime.now(),
    );
  }
}
