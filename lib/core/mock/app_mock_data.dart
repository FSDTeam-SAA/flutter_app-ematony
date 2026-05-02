import 'dart:convert';

class AppMockData {
  AppMockData._();

  static int _groupSeed = 123459;

  static Map<String, dynamic> _currentUser = {
    '_id': 'user-001',
    'name': 'Amina Balogun',
    'email': 'amina@ajofamily.app',
    'phone': '+234 803 555 0112',
    'role': 'member',
    'kycVerified': true,
  };

  static final List<Map<String, dynamic>> _transactions = [
    _transaction(
      id: 'txn-001',
      type: 'topup',
      amount: 2000,
      status: 'complete',
      createdAt: '2026-05-02T09:30:00.000Z',
    ),
    _transaction(
      id: 'txn-002',
      type: 'withdraw',
      amount: 2000,
      status: 'complete',
      createdAt: '2026-05-01T16:10:00.000Z',
    ),
    _transaction(
      id: 'txn-003',
      type: 'topup',
      amount: 5000,
      status: 'complete',
      createdAt: '2026-04-30T10:25:00.000Z',
    ),
    _transaction(
      id: 'txn-004',
      type: 'withdraw',
      amount: 1500,
      status: 'pending',
      createdAt: '2026-04-29T14:45:00.000Z',
    ),
    _transaction(
      id: 'txn-005',
      type: 'topup',
      amount: 3500,
      status: 'complete',
      createdAt: '2026-04-28T12:00:00.000Z',
    ),
  ];

  static final List<Map<String, dynamic>> _notifications = [
    _notification(
      id: 'ntf-001',
      title: 'You top up ₦2000 in your wallet.',
      content: 'Wallet funded successfully this morning.',
      createdAt: '2026-05-02T09:32:00.000Z',
    ),
    _notification(
      id: 'ntf-002',
      title: 'You withdraw ₦2000 from your wallet.',
      content: 'Transfer to your bank is being processed.',
      createdAt: '2026-05-01T16:14:00.000Z',
    ),
    _notification(
      id: 'ntf-003',
      title: 'Ajo Family Circle contribution is due tomorrow.',
      content: 'Enable auto payment to stay on track.',
      createdAt: '2026-04-30T08:20:00.000Z',
    ),
    _notification(
      id: 'ntf-004',
      title: 'You have been added to School Project Fund.',
      content: 'Open the group to view the next wheel date.',
      createdAt: '2026-04-29T11:05:00.000Z',
    ),
  ];

  static final List<Map<String, dynamic>> _activeGroups = [
    _group(
      id: 'grp-001',
      name: 'Ajo Family Circle',
      description: 'Monthly family savings rotation for home projects.',
      inviteCode: '123456',
      contributionAmount: 25000,
      contributionFrequency: 'Monthly',
      maxMembers: 10,
      memberCount: 8,
      status: 'active',
      nextWheelDate: '12 May 2026',
    ),
    _group(
      id: 'grp-002',
      name: 'Market Women Trust',
      description: 'Weekly contribution club for expanding market stalls.',
      inviteCode: '221148',
      contributionAmount: 12000,
      contributionFrequency: 'Weekly',
      maxMembers: 12,
      memberCount: 9,
      status: 'active',
      nextWheelDate: '08 May 2026',
    ),
  ];

  static final List<Map<String, dynamic>> _requestGroups = [
    _group(
      id: 'grp-003',
      name: 'School Project Fund',
      description: 'Save together for school fees and supplies.',
      inviteCode: '654321',
      contributionAmount: 15000,
      contributionFrequency: 'Monthly',
      maxMembers: 8,
      memberCount: 5,
      status: 'request',
      nextWheelDate: '16 May 2026',
    ),
    _group(
      id: 'grp-004',
      name: 'Sunday Estate Friends',
      description: 'Neighbourhood savings group for shared investments.',
      inviteCode: '778899',
      contributionAmount: 18000,
      contributionFrequency: 'Monthly',
      maxMembers: 10,
      memberCount: 6,
      status: 'request',
      nextWheelDate: '20 May 2026',
    ),
  ];

  static final Map<String, List<Map<String, dynamic>>> _groupMembers = {
    'grp-001': [
      _member(
        id: 'member-001',
        name: 'Amina Balogun',
        role: 'creator',
        paymentStatus: 'paid',
        payoutPosition: 1,
      ),
      _member(
        id: 'member-002',
        name: 'Daniel Okafor',
        role: 'member',
        paymentStatus: 'paid',
        payoutPosition: 2,
      ),
      _member(
        id: 'member-003',
        name: 'Kemi Ajayi',
        role: 'member',
        paymentStatus: 'pending',
        payoutPosition: 3,
      ),
      _member(
        id: 'member-004',
        name: 'Tolu Hassan',
        role: 'member',
        paymentStatus: 'paid',
        payoutPosition: 4,
      ),
    ],
    'grp-002': [
      _member(
        id: 'member-005',
        name: 'Bola Kareem',
        role: 'creator',
        paymentStatus: 'paid',
        payoutPosition: 1,
      ),
      _member(
        id: 'member-006',
        name: 'Ngozi Umeh',
        role: 'member',
        paymentStatus: 'pending',
        payoutPosition: 2,
      ),
      _member(
        id: 'member-007',
        name: 'Lara Peter',
        role: 'member',
        paymentStatus: 'paid',
        payoutPosition: 3,
      ),
      _member(
        id: 'member-008',
        name: 'Segun David',
        role: 'member',
        paymentStatus: 'pending',
        payoutPosition: 4,
      ),
    ],
    'grp-003': [
      _member(
        id: 'member-009',
        name: 'Favour Nnaji',
        role: 'creator',
        paymentStatus: 'paid',
        payoutPosition: 1,
      ),
      _member(
        id: 'member-010',
        name: 'Ruth Ojo',
        role: 'member',
        paymentStatus: 'pending',
        payoutPosition: 2,
      ),
    ],
    'grp-004': [
      _member(
        id: 'member-011',
        name: 'Ibrahim Yusuf',
        role: 'creator',
        paymentStatus: 'paid',
        payoutPosition: 1,
      ),
      _member(
        id: 'member-012',
        name: 'Peace Ekanem',
        role: 'member',
        paymentStatus: 'pending',
        payoutPosition: 2,
      ),
    ],
  };

  static Map<String, dynamic> currentUser() => _cloneMap(_currentUser);

  static void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = _cloneMap(user);
  }

  static Future<void> simulateDelay([int milliseconds = 250]) {
    return Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  static Map<String, dynamic> loginUser({
    required String email,
    String? name,
    String? phone,
    bool verified = true,
  }) {
    final fallbackName = name == null || name.trim().isEmpty ? 'Amina Balogun' : name.trim();
    final digits = (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    _currentUser = {
      '_id': verified ? 'user-verified' : 'user-pending',
      'name': fallbackName,
      'email': email,
      'phone': phone?.trim().isNotEmpty == true ? phone!.trim() : '+234 ${digits.padRight(10, '0')}',
      'role': 'member',
      'kycVerified': verified,
    };
    return currentUser();
  }

  static Map<String, dynamic> buildHomeDashboard() {
    final firstGroup = _activeGroups.first;
    return {
      'walletSummary': {'balance': 34671.80},
      'upcomingPayment': {
        'groupName': firstGroup['name'],
        'amount': firstGroup['contributionAmount'],
      },
      'activeGroups': _activeGroups.length,
      'pendingRequests': _requestGroups.length,
      'recentTransactions': _cloneList(_transactions),
      'recentNotifications': _cloneList(_notifications),
    };
  }

  static List<Map<String, dynamic>> activeGroups() => _cloneList(_activeGroups);

  static List<Map<String, dynamic>> requestGroups() => _cloneList(_requestGroups);

  static Map<String, dynamic> walletData() {
    return {
      'balance': 34671.80,
      'transactions': _cloneList(_transactions),
    };
  }

  static List<Map<String, dynamic>> transactions() => _cloneList(_transactions);

  static List<Map<String, dynamic>> notifications() => _cloneList(_notifications);

  static Map<String, dynamic> groupDetail(String groupId) {
    final group = _findGroup(groupId);
    return {
      'group': _cloneMap(group),
      'totalPool': (group['contributionAmount'] as num).toDouble() *
          ((group['memberCount'] as num).toDouble()),
      'nextWheelDate': group['nextWheelDate'],
      'upcomingPaymentAmount': group['contributionAmount'],
    };
  }

  static List<Map<String, dynamic>> groupMembers(String groupId) {
    final members = _groupMembers[groupId] ?? <Map<String, dynamic>>[];
    return _cloneList(members);
  }

  static Map<String, dynamic> groupWheel(String groupId) {
    final members = _groupMembers[groupId] ?? <Map<String, dynamic>>[];
    return {
      'groupId': groupId,
      'nextWheelDate': _findGroup(groupId)['nextWheelDate'],
      'rotations': List.generate(members.length, (index) {
        final member = members[index];
        final user = member['userId'] as Map<String, dynamic>;
        return {
          'positionNumber': index + 1,
          'user': {
            'name': user['name'],
            'email': user['email'],
          },
        };
      }),
    };
  }

  static String joinByCode(String inviteCode) {
    final normalized = inviteCode.replaceAll('#', '').trim();
    if (normalized.isEmpty) {
      throw Exception('Enter a valid group code.');
    }

    final existingActive = _activeGroups.where((group) => group['inviteCode'] == normalized);
    if (existingActive.isNotEmpty) {
      return existingActive.first['_id'] as String;
    }

    final index = _requestGroups.indexWhere((group) => group['inviteCode'] == normalized);
    if (index == -1) {
      throw Exception('Group code not found.');
    }

    final group = Map<String, dynamic>.from(_requestGroups.removeAt(index));
    group['status'] = 'active';
    group['memberCount'] = ((group['memberCount'] as int) + 1).clamp(1, group['maxMembers'] as int);
    _activeGroups.insert(0, group);
    _ensureCurrentUserMembership(group['_id'] as String);
    return group['_id'] as String;
  }

  static void joinGroup(String groupId) {
    final index = _requestGroups.indexWhere((group) => group['_id'] == groupId);
    if (index == -1) {
      return;
    }
    final group = Map<String, dynamic>.from(_requestGroups.removeAt(index));
    group['status'] = 'active';
    group['memberCount'] = ((group['memberCount'] as int) + 1).clamp(1, group['maxMembers'] as int);
    _activeGroups.insert(0, group);
    _ensureCurrentUserMembership(groupId);
  }

  static Map<String, dynamic> createGroup({
    required String name,
    required String amount,
    required String frequency,
    required String maxMembers,
    required String cycleDuration,
    required bool autoPayments,
  }) {
    final groupId = 'grp-${_groupSeed++}';
    final inviteCode = (_groupSeed + 400000).toString().substring(0, 6);
    final contributionAmount = double.tryParse(amount) ?? 0;
    final members = int.tryParse(maxMembers) ?? 10;
    final duration = int.tryParse(cycleDuration) ?? members;
    final group = _group(
      id: groupId,
      name: name.isEmpty ? 'New Savings Group' : name,
      description: autoPayments
          ? 'Automatic group contributions are enabled.'
          : 'Manual group contributions are enabled.',
      inviteCode: inviteCode,
      contributionAmount: contributionAmount <= 0 ? 10000 : contributionAmount,
      contributionFrequency: frequency,
      maxMembers: members,
      memberCount: 1,
      status: 'active',
      nextWheelDate: duration > 6 ? '25 May 2026' : '12 May 2026',
    );
    _activeGroups.insert(0, group);
    _groupMembers[groupId] = [
      _member(
        id: 'member-${_groupSeed}',
        name: _currentUser['name'] as String,
        role: 'creator',
        paymentStatus: 'paid',
        payoutPosition: 1,
      ),
    ];
    return _cloneMap(group);
  }

  static Map<String, dynamic> _findGroup(String groupId) {
    final groups = <Map<String, dynamic>>[
      ..._activeGroups,
      ..._requestGroups,
    ];
    return groups.firstWhere(
      (group) => group['_id'] == groupId,
      orElse: () => _cloneMap(_activeGroups.first),
    );
  }

  static void _ensureCurrentUserMembership(String groupId) {
    final members = _groupMembers.putIfAbsent(groupId, () => <Map<String, dynamic>>[]);
    final userId = _currentUser['_id'] as String;
    final alreadyJoined = members.any((member) {
      final user = member['userId'] as Map<String, dynamic>;
      return user['_id'] == userId;
    });
    if (!alreadyJoined) {
      members.add(
        _member(
          id: 'member-${_groupSeed++}',
          name: _currentUser['name'] as String,
          role: 'member',
          paymentStatus: 'pending',
          payoutPosition: members.length + 1,
        ),
      );
    }
  }

  static Map<String, dynamic> _group({
    required String id,
    required String name,
    required String description,
    required String inviteCode,
    required double contributionAmount,
    required String contributionFrequency,
    required int maxMembers,
    required int memberCount,
    required String status,
    required String nextWheelDate,
  }) {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'inviteCode': inviteCode,
      'contributionAmount': contributionAmount,
      'contributionFrequency': contributionFrequency,
      'maxMembers': maxMembers,
      'memberCount': memberCount,
      'status': status,
      'nextWheelDate': nextWheelDate,
    };
  }

  static Map<String, dynamic> _member({
    required String id,
    required String name,
    required String role,
    required String paymentStatus,
    required int payoutPosition,
  }) {
    return {
      '_id': id,
      'userId': {
        '_id': id,
        'name': name,
        'email': '${name.toLowerCase().replaceAll(' ', '.')}@ajofamily.app',
      },
      'membershipRole': role,
      'paymentStatus': paymentStatus,
      'payoutPosition': payoutPosition,
      'updatedAt': '2026-05-02T09:00:00.000Z',
    };
  }

  static Map<String, dynamic> _transaction({
    required String id,
    required String type,
    required double amount,
    required String status,
    required String createdAt,
  }) {
    return {
      '_id': id,
      'type': type,
      'amount': amount,
      'price': amount,
      'paymentStatus': status,
      'createdAt': createdAt,
    };
  }

  static Map<String, dynamic> _notification({
    required String id,
    required String title,
    required String content,
    required String createdAt,
  }) {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  static Map<String, dynamic> _cloneMap(Map<String, dynamic> value) {
    return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> _cloneList(List<Map<String, dynamic>> value) {
    final raw = jsonDecode(jsonEncode(value)) as List<dynamic>;
    return raw.cast<Map<String, dynamic>>();
  }
}
