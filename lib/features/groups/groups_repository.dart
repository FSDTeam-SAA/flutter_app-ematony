import 'package:dio/dio.dart';
import '../../core/mock/app_mock_data.dart';
import '../../core/models/group_model.dart';
import '../../core/network/api_client.dart';

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
    } on DioException {
      return AppMockData.activeGroups().map(GroupModel.fromJson).toList();
    }
  }

  Future<List<GroupModel>> listGroupRequests() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/requests');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((json) {
              final groupJson = json['groupId'] as Map<String, dynamic>?;
              if (groupJson != null) return GroupModel.fromJson(groupJson);
              return GroupModel.fromJson(json);
            })
            .toList();
      }
      return [];
    } on DioException {
      return AppMockData.requestGroups().map(GroupModel.fromJson).toList();
    }
  }

  Future<Map<String, dynamic>> getGroupDetails(String id) async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id');
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException {
      return AppMockData.groupDetail(id);
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
    } on DioException {
      return AppMockData.groupMembers(id)
          .map(GroupMemberModel.fromJson)
          .toList();
    }
  }

  Future<String> createGroup({
    required String name,
    required double amount,
    required String frequency,
    required int maxMembers,
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
      });
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final group = data['group'] as Map<String, dynamic>?;
      final inviteCode =
          (data['inviteCode'] ?? group?['inviteCode'] ?? '').toString();
      return inviteCode;
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final mock = AppMockData.createGroup(
          name: name,
          amount: amount.toString(),
          frequency: frequency,
          maxMembers: maxMembers.toString(),
          cycleDuration: maxMembers.toString(),
          autoPayments: autoPayments,
        );
        return '#${mock['inviteCode']}';
      }
      throw Exception(msg ?? 'Failed to create group.');
    }
  }

  Future<String> joinByCode(String code) async {
    final normalized = code.replaceAll('#', '').trim().toUpperCase();
    try {
      final response =
          await _apiClient.dio.post<Map<String, dynamic>>('/groups/join-by-code',
              data: {'inviteCode': normalized});
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final groupId = (data['groupId'] ?? data['_id'] ?? '').toString();
      return groupId;
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return AppMockData.joinByCode(normalized);
      }
      throw Exception(msg ?? 'Group code not found.');
    }
  }
}
