import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/intelligence/presentation/state/intelligence_state.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/intelligence_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class VaidyaAiScreen extends ConsumerStatefulWidget {
  const VaidyaAiScreen({super.key});

  @override
  ConsumerState<VaidyaAiScreen> createState() => _VaidyaAiScreenState();
}

class _VaidyaAiScreenState extends ConsumerState<VaidyaAiScreen> {
  static const String _doctorSlug = 'nischay-maharan';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  late List<_ChatMessageViewData> _messages = const [
    _ChatMessageViewData(
      role: 'assistant',
      content:
          "Hi there! I'm Vaidya.ai. Tell me what you'd like help with today.",
    ),
  ];

  bool _isSending = false;

  bool get _hasChatStarted => _messages.length > 1;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || _isSending) {
      return;
    }

    final userMessage = _ChatMessageViewData(role: 'user', content: trimmed);

    setState(() {
      _messages = [..._messages, userMessage];
      _isSending = true;
      _inputController.clear();
    });
    _scrollToBottom();

    final requestMessages = _messages
        .map((item) => item.toApiPayload())
        .toList(growable: false);
    final payload = requestMessages.length <= 20
        ? requestMessages
        : requestMessages.sublist(requestMessages.length - 20);

    final ok = await ref
        .read(intelligenceViewModelProvider.notifier)
        .chat(messages: payload, doctor: _doctorSlug);
    if (!mounted) return;

    final latestState = ref.read(intelligenceViewModelProvider);
    final replyText = latestState.lastReply?.reply.trim() ?? '';

    setState(() {
      _messages = [
        ..._messages,
        _ChatMessageViewData(
          role: 'assistant',
          content: ok && replyText.isNotEmpty
              ? replyText
              : 'I ran into an issue while responding. Please try again.',
        ),
      ];
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _openMainTab(MainBottomNavItem item) {
    final targetIndex = switch (item) {
      MainBottomNavItem.home => 0,
      MainBottomNavItem.records => 1,
      MainBottomNavItem.intelligence => 2,
      MainBottomNavItem.analytics => 3,
      MainBottomNavItem.profile => 4,
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialIndex: targetIndex),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<IntelligenceState>(intelligenceViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                style: const TextStyle(fontFamily: 'Urbanist'),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.vaidyaAi,
      ),
      bottomNavigationBar: AppMainBottomNav(
        activeItem: null,
        onTap: _openMainTab,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: AppDrawerToggleButton(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: const Text(
          'Vaidya.ai',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: _hasChatStarted ? _buildTranscript() : _buildWelcome(),
            ),
            _Composer(
              controller: _inputController,
              focusNode: _inputFocusNode,
              isSending: _isSending,
              onSend: () => _sendMessage(_inputController.text),
              onTextChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'How can I help you today?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: AppColors.textPrimary,
                        fontSize: 38,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'I can help with symptoms, medications, care plans, and wellness guidance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscript() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: _messages.length + (_isSending ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isSending && index == _messages.length) {
              return const _ChatBubble(
                roleLabel: 'Vaidya.ai',
                content: 'Thinking...',
                isUser: false,
              );
            }

            final message = _messages[index];
            return _ChatBubble(
              roleLabel: message.isUser ? 'You' : 'Vaidya.ai',
              content: message.content,
              isUser: message.isUser,
            );
          },
        ),
      ),
    );
  }
}

class _PromptCardData {
  final String title;
  final String description;

  const _PromptCardData({required this.title, required this.description});
}

class _PromptCard extends StatelessWidget {
  final _PromptCardData card;
  final VoidCallback onTap;

  const _PromptCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFDFE),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 19,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.description,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14.5,
                  height: 1.3,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessageViewData {
  final String role;
  final String content;

  const _ChatMessageViewData({required this.role, required this.content});

  bool get isUser => role == 'user';

  Map<String, String> toApiPayload() => {'role': role, 'content': content};
}

class _ChatBubble extends StatelessWidget {
  final String roleLabel;
  final String content;
  final bool isUser;

  const _ChatBubble({
    required this.roleLabel,
    required this.content,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.79,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0x1A1F7AE0) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleLabel,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final ValueChanged<String> onTextChanged;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    onChanged: onTextChanged,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Message Vaidya.ai',
                      hintStyle: TextStyle(
                        fontFamily: 'Urbanist',
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isSending || !hasText ? null : onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFF1F5F9),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    minimumSize: const Size(40, 40),
                    maximumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
