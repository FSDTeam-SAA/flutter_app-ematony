import '../utils/currency_utils.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final double contributionAmount;
  final String contributionFrequency;
  final int maxMembers;
  final String status;
  final String currencyCode;
  final bool autoPaymentsEnabled;
  final int reminderDaysBefore;
  final int gracePeriodHours;
  final double lateFeePercent;
  final double adminPayoutPercent;
  final String wheelMode;
  final DateTime? startDate;
  final DateTime? endDate;
  int membersCount;
  final String paymentStatus;

  GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.inviteCode,
    required this.contributionAmount,
    this.contributionFrequency = 'monthly',
    required this.maxMembers,
    this.status = 'active',
    this.currencyCode = 'NGN',
    this.autoPaymentsEnabled = false,
    this.reminderDaysBefore = 2,
    this.gracePeriodHours = 24,
    this.lateFeePercent = 7.5,
    this.adminPayoutPercent = 1,
    this.wheelMode = 'serial',
    this.startDate,
    this.endDate,
    this.membersCount = 1,
    this.paymentStatus = 'pending',
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? json['groupCode'] ?? '').toString(),
      contributionAmount:
          (json['contributionAmount'] as num?)?.toDouble() ?? 0.0,
      contributionFrequency:
          (json['contributionFrequency'] ?? json['frequency'] ?? 'monthly')
              .toString(),
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
      status: (json['status'] ?? 'active').toString(),
      currencyCode: (json['currencyCode'] ?? 'NGN').toString(),
      autoPaymentsEnabled: json['autoPaymentsEnabled'] == true,
      reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 2,
      gracePeriodHours: (json['gracePeriodHours'] as num?)?.toInt() ?? 24,
      lateFeePercent: (json['lateFeePercent'] as num?)?.toDouble() ?? 7.5,
      adminPayoutPercent:
          (json['adminPayoutPercent'] as num?)?.toDouble() ?? 1.0,
      wheelMode: (json['wheelMode'] ?? 'serial').toString(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      membersCount: (json['membersCount'] as num?)?.toInt() ??
          (json['memberCount'] as num?)?.toInt() ??
          1,
      paymentStatus: (json['paymentStatus'] ?? 'pending').toString(),
    );
  }

  bool get hasPendingPayment => paymentStatus != 'paid';

  double get completionPercent {
    if (maxMembers <= 0) return 0;
    return (membersCount / maxMembers).clamp(0.0, 1.0);
  }

  String get formattedAmount {
    return formatCurrencyAmount(contributionAmount, currencyCode);
  }

  String get frequencyLabel {
    switch (contributionFrequency.toLowerCase()) {
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-Weekly';
      default:
        return 'Monthly';
    }
  }
}

class GroupMemberModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String membershipRole;
  final int payoutPosition;
  final bool isLastWinner;

  GroupMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.membershipRole,
    required this.payoutPosition,
    this.isLastWinner = false,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] is Map<String, dynamic>
        ? json['userId'] as Map<String, dynamic>
        : <String, dynamic>{};
    final user2 = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final effectiveUser = user.isNotEmpty ? user : user2;
    return GroupMemberModel(
      id: (json['_id'] ?? json['membershipId'] ?? '').toString(),
      userId: (effectiveUser['_id'] ?? '').toString(),
      name: (effectiveUser['name'] ?? effectiveUser['firstName'] ?? 'Member')
          .toString(),
      email: (effectiveUser['email'] ?? '').toString(),
      membershipRole: (json['membershipRole'] ?? 'member').toString(),
      payoutPosition: (json['payoutPosition'] as num?)?.toInt() ?? 0,
      isLastWinner: json['isLastWinner'] == true,
    );
  }
}
