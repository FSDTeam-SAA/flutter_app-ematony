import '../utils/currency_utils.dart';

class PaymentModel {
  final String id;
  final double price;
  final String type;
  final String paymentStatus;
  final DateTime createdAt;
  final String? transactionId;
  final String currencyCode;
  final double baseAmount;
  final bool lateFeeApplied;
  final double lateFeeAmount;
  final double adminCreditAmount;

  PaymentModel({
    required this.id,
    required this.price,
    required this.type,
    required this.paymentStatus,
    required this.createdAt,
    this.transactionId,
    this.currencyCode = 'NGN',
    this.baseAmount = 0,
    this.lateFeeApplied = false,
    this.lateFeeAmount = 0,
    this.adminCreditAmount = 0,
  });

  bool get isTopUp =>
      type == 'wallet_topup' ||
      type == 'topup' ||
      type == 'payout' ||
      type == 'refund' ||
      type == 'admin_commission' ||
      type == 'late_fee_admin_credit';

  bool get isWithdraw =>
      type == 'withdraw' || type == 'group_contribution';

  String get title {
    switch (type) {
      case 'wallet_topup':
      case 'topup':
        return 'Top Up';
      case 'payout':
        return 'Group Payout';
      case 'withdraw':
        return 'Withdraw';
      case 'group_contribution':
        return lateFeeApplied ? 'Contribution + Late Fee' : 'Contribution';
      case 'late_fee_admin_credit':
        return 'Late Fee Credit';
      case 'admin_commission':
        return 'Admin Commission';
      case 'refund':
        return 'Refund';
      case 'adjustment':
        return 'Adjustment';
      default:
        return 'Transaction';
    }
  }

  String get formattedAmount {
    return formatCurrencyAmount(price, currencyCode);
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
    final priceRaw = json['price'] ?? json['amount'];
    final price = priceRaw is num ? priceRaw.toDouble() : 0.0;
    return PaymentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      price: price,
      type: (json['type'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? json['status'] ?? '').toString(),
      createdAt: createdAtRaw.isNotEmpty
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      transactionId: json['transactionId']?.toString(),
      currencyCode: (json['currencyCode'] ?? 'NGN').toString(),
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0,
      lateFeeApplied: json['lateFeeApplied'] == true,
      lateFeeAmount: (json['lateFeeAmount'] as num?)?.toDouble() ?? 0,
      adminCreditAmount:
          (json['adminCreditAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  factory PaymentModel.fromWithdrawalJson(Map<String, dynamic> json) {
    final createdAtRaw = (json['createdAt'] ?? json['requestedAt'] ?? '')
        .toString();
    final amountRaw = json['amount'] ?? json['price'];
    final amount = amountRaw is num ? amountRaw.toDouble() : 0.0;
    return PaymentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      price: amount,
      type: 'withdraw',
      paymentStatus: (json['status'] ?? '').toString(),
      createdAt: createdAtRaw.isNotEmpty
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      currencyCode: (json['currencyCode'] ?? 'NGN').toString(),
    );
  }
}
