import 'package:dio/dio.dart';

import '../../core/models/group_model.dart';
import '../../core/network/api_client.dart';

String _extractDioMessage(DioException e) {
  try {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Cannot reach the server. Check your internet.';
  }
  return e.message ?? 'Request failed';
}

class GroupsRepository {
  GroupsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<GroupModel>> listMyGroups() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(GroupModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<List<GroupModel>> listGroupRequests() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/requests');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map((json) {
          final groupJson = json['groupId'] as Map<String, dynamic>?;
          if (groupJson != null) return GroupModel.fromJson(groupJson);
          return GroupModel.fromJson(json);
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<Map<String, dynamic>> getGroupDetails(String id) async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id');
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<List<GroupMemberModel>> getGroupMembers(String id) async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id/members');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(GroupMemberModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<Map<String, dynamic>> getGroupWheel(String id) async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id/wheel');
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<Map<String, dynamic>> spinGroupWheel(String id) async {
    try {
      final response = await _apiClient.dio
          .post<Map<String, dynamic>>('/groups/$id/wheel/spin');
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<String> createGroup({
    required String name,
    required double amount,
    required String frequency,
    required int maxMembers,
    required String currencyCode,
    required bool autoPayments,
  }) async {
    try {
      final response =
          await _apiClient.dio.post<Map<String, dynamic>>('/groups', data: {
        'name': name,
        'contributionAmount': amount,
        'contributionFrequency': frequency,
        'frequency': frequency,
        'maxMembers': maxMembers,
        'currencyCode': currencyCode,
        'autoPaymentsEnabled': autoPayments,
        'autoPayments': autoPayments,
      });
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final group = data['group'] as Map<String, dynamic>?;
      final inviteCode =
          (data['inviteCode'] ?? group?['inviteCode'] ?? '').toString();
      return inviteCode;
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<String> joinByCode(String code) async {
    final normalized = code.replaceAll('#', '').trim().toUpperCase();
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
          '/groups/join-by-code',
          data: {'inviteCode': normalized});
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final groupId = (data['groupId'] ?? data['_id'] ?? '').toString();
      return groupId;
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      await _apiClient.dio.patch('/groups/requests/$requestId/approve');
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _apiClient.dio.patch('/groups/requests/$requestId/reject');
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }
}
