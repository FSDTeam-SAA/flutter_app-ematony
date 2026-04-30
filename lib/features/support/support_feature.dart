import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/labeled_text_field.dart';
import '../../core/widgets/member_shell.dart';

class SupportRepository {
  SupportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<SupportTicket>> fetchTickets() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/support/tickets');
    final raw = response.data?['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SupportTicketDetail> fetchTicketDetail(String id) async {
    final response =
        await _apiClient.dio.get<Map<String, dynamic>>('/support/tickets/$id');
    final payload = response.data?['data'] as Map<String, dynamic>? ?? {};
    return SupportTicketDetail.fromJson(payload);
  }

  Future<void> createTicket({
    required String groupId,
    required String category,
    required String subject,
    required String message,
  }) async {
    await _apiClient.dio.post(
      '/support/tickets',
      data: {
        'groupId': groupId.isEmpty ? null : groupId,
        'category': category,
        'subject': subject,
        'message': message,
      },
    );
  }

  Future<void> reply({
    required String ticketId,
    required String message,
  }) async {
    await _apiClient.dio.post(
      '/support/tickets/$ticketId/messages',
      data: {'message': message},
    );
  }

  Future<void> close(String ticketId) async {
    await _apiClient.dio.patch('/support/tickets/$ticketId/close');
  }
}

class SupportTicket {
  SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String subject;
  final String category;
  final String status;
  final DateTime updatedAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: (json['_id'] ?? '').toString(),
      subject: (json['subject'] ?? 'Support request').toString(),
      category: (json['category'] ?? 'General').toString(),
      status: (json['status'] ?? 'open').toString(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class SupportMessage {
  SupportMessage({
    required this.message,
    required this.senderRole,
    required this.createdAt,
  });

  final String message;
  final String senderRole;
  final DateTime createdAt;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      message: (json['message'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? 'member').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class SupportTicketDetail {
  SupportTicketDetail({
    required this.ticket,
    required this.messages,
  });

  final SupportTicket ticket;
  final List<SupportMessage> messages;

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    return SupportTicketDetail(
      ticket: SupportTicket.fromJson(json['ticket'] as Map<String, dynamic>? ?? {}),
      messages: ((json['messages'] as List<dynamic>? ?? []))
          .map((item) => SupportMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SupportController extends ChangeNotifier {
  SupportController({required SupportRepository repository}) : _repository = repository;

  final SupportRepository _repository;

  List<SupportTicket> tickets = [];
  SupportTicketDetail? detail;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      tickets = await _repository.fetchTickets();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      detail = await _repository.fetchTicketDetail(id);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket({
    required String groupId,
    required String category,
    required String subject,
    required String message,
  }) async {
    try {
      await _repository.createTicket(
        groupId: groupId,
        category: category,
        subject: subject,
        message: message,
      );
      await load();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reply({
    required String ticketId,
    required String message,
  }) async {
    try {
      await _repository.reply(ticketId: ticketId, message: message);
      await loadDetail(ticketId);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> close(String ticketId) async {
    try {
      await _repository.close(ticketId);
      await loadDetail(ticketId);
      await load();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupportController>();

    return MemberShell(
      currentIndex: 2,
      title: 'Support',
      actions: [
        IconButton(
          onPressed: () => context.push('/support/new'),
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Contact admin and track your requests.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
            const SizedBox(height: 16),
            if (controller.isLoading && controller.tickets.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.tickets.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No support tickets yet. Tap the add button to contact admin.'),
                ),
              )
            else
              ...controller.tickets.map(
                (ticket) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      title: Text(ticket.subject),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${ticket.category} • ${DateFormat('dd MMM').format(ticket.updatedAt)}',
                        ),
                      ),
                      trailing: Chip(label: Text(ticket.status)),
                      onTap: () => context.push('/support/${ticket.id}'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({super.key});

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final _fullNameController = TextEditingController();
  final _groupController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Payment/Transaction');
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _groupController.dispose();
    _categoryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupportController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Admin')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      LabeledTextField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        hintText: 'Gregory',
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Group Name',
                        controller: _groupController,
                        hintText: 'Family Savings - 2026',
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Issue Category',
                        controller: _categoryController,
                        hintText: 'Payment/Transaction',
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Message',
                        controller: _messageController,
                        hintText: 'Write your message here...',
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final ok = await controller.createTicket(
                                groupId: _groupController.text.trim(),
                                category: _categoryController.text.trim(),
                                subject: _fullNameController.text.trim().isEmpty
                                    ? 'Contact Admin'
                                    : _fullNameController.text.trim(),
                                message: _messageController.text.trim(),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Ticket submitted successfully'
                                        : controller.errorMessage ?? 'Submission failed',
                                  ),
                                ),
                              );
                              if (ok) {
                                context.pop();
                              }
                            },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportDetailScreen extends StatefulWidget {
  const SupportDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportController>().loadDetail(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupportController>();
    final detail = controller.detail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Ticket'),
        actions: [
          if (detail != null && detail.ticket.status != 'closed')
            TextButton(
              onPressed: () async {
                final ok = await controller.close(widget.ticketId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Ticket closed' : controller.errorMessage ?? 'Close failed'),
                  ),
                );
              },
              child: const Text('Close'),
            ),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading && detail == null
            ? const Center(child: CircularProgressIndicator())
            : detail == null
                ? Center(child: Text(controller.errorMessage ?? 'Ticket not found'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail.ticket.subject,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Category: ${detail.ticket.category}'),
                                    const SizedBox(height: 8),
                                    Chip(label: Text(detail.ticket.status)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...detail.messages.map(
                              (message) => Align(
                                alignment: message.senderRole == 'admin'
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  constraints: const BoxConstraints(maxWidth: 320),
                                  decoration: BoxDecoration(
                                    color: message.senderRole == 'admin'
                                        ? AppColors.subtle
                                        : const Color(0xFFEAF1FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message.message),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat('dd MMM, hh:mm a').format(message.createdAt),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (detail.ticket.status != 'closed')
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replyController,
                                    decoration: const InputDecoration(
                                      hintText: 'Write a reply...',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: () async {
                                    final ok = await controller.reply(
                                      ticketId: widget.ticketId,
                                      message: _replyController.text.trim(),
                                    );
                                    if (!mounted) return;
                                    if (ok) {
                                      _replyController.clear();
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? 'Reply sent'
                                              : controller.errorMessage ?? 'Reply failed',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
