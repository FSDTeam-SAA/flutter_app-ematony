class PaymentModel {
  final String id;
  final double price;
  final String type;
  final String paymentStatus;
  final DateTime createdAt;
  final String? transactionId;

  PaymentModel({
    required this.id,
    required this.price,
    required this.type,
    required this.paymentStatus,
    required this.createdAt,
    this.transactionId,
  });

  bool get isTopUp =>
      type == 'wallet_topup' || type == 'topup';

  bool get isWithdraw =>
      type == 'payout' || type == 'withdraw';

  String get title {
    switch (type) {
      case 'wallet_topup':
      case 'topup':
        return 'Top Up';
      case 'payout':
      case 'withdraw':
        return 'Withdraw';
      case 'group_contribution':
        return 'Contribution';
      case 'refund':
        return 'Refund';
      case 'adjustment':
        return 'Adjustment';
      default:
        return 'Transaction';
    }
  }

  String get formattedAmount {
    final formatted = price
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '₦$formatted';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Just Now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt']?.toString() ?? '';
    return PaymentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      price: (json['price'] ?? json['amount'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? json['status'] ?? '').toString(),
      createdAt:
          createdAtRaw.isNotEmpty ? DateTime.tryParse(createdAtRaw) ?? DateTime.now() : DateTime.now(),
      transactionId: json['transactionId']?.toString(),
    );
  }
}
