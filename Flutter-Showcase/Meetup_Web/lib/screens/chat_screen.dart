import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_rtc/models/poll_message.dart';
import 'package:web_rtc/services/webrtc_service.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const ChatScreen({super.key, this.onClose});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();

  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    controller = ChatController();
    controller.attach(context);
  }

  @override
  void dispose() {
    _chatController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _sendChat() {
    final text = _chatController.text;
    if (text.trim().isNotEmpty) {
      controller.sendChat(text);
      _chatController.clear();
    }
  }

  // ─── Create Poll Bottom Sheet ─────────────────────────────────────────────

  void _showCreatePollSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CreatePollSheet(
        onSubmit: (question, options) {
          controller.sendPoll(question, options);
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: colorScheme.surfaceContainer,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: widget.onClose == null,
        actions: [if (widget.onClose != null) CloseButton(onPressed: widget.onClose!)],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Consumer<WebRTCService>(
            builder: (context, service, _) {
              final timeline = controller.buildTimeline();
          return Column(
            children: [
              Expanded(
                child: timeline.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: colorScheme.outlineVariant),
                            Text('No messages yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: timeline.length,
                        itemBuilder: (context, index) {
                          final item = timeline[timeline.length - 1 - index];
                          return item.isPoll
                              ? _PollCard(poll: item.poll!, service: service, controller: controller)
                              : _ChatBubble(msg: item.chat!, localName: service.localUserName);
                        },
                      ),
              ),
              Container(
                color: colorScheme.surfaceContainer,
                padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  spacing: 6,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.poll_outlined),
                      tooltip: 'Create Poll',
                      color: colorScheme.primary,
                      onPressed: () => _showCreatePollSheet(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _sendChat(),
                      ),
                    ),
                    IconButton.filled(icon: const Icon(Icons.send, size: 20), onPressed: _sendChat),
                  ],
                ),
              ),
            ],
          );
        },
      );
        },
      ),
    );
  }
}

// ─── Chat Bubble ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final String localName;
  const _ChatBubble({required this.msg, required this.localName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMe = msg.sender == localName;
    final label = isMe ? 'Me' : msg.sender;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(label, style: textTheme.labelSmall?.copyWith(color: isMe ? colorScheme.primary : colorScheme.onSurfaceVariant)),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 12, left: isMe ? 40 : 0, right: isMe ? 0 : 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(topRight: isMe ? Radius.zero : const Radius.circular(20), topLeft: !isMe ? Radius.zero : const Radius.circular(20)),
            ),
            child: Text(msg.text, style: textTheme.bodyMedium?.copyWith(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}

// ─── Poll Card ────────────────────────────────────────────────────────────────

class _PollCard extends StatefulWidget {
  final PollMessage poll;
  final WebRTCService service;
  final ChatController controller;
  const _PollCard({required this.poll, required this.service, required this.controller});

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  void _handleVote(int i) {
    // Optimistic local setState for instant visual feedback
    setState(() {});
    widget.controller.voteOnPoll(widget.poll.pollId, i);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final poll = widget.poll;
    final service = widget.service;
    final isMe = poll.sender == service.localUserName;
    final total = poll.totalVotes;
    final hasVoted = poll.localVotedIndex >= 0;
    // Show results bars once anyone has voted OR this user has voted
    final showResults = hasVoted || total > 0;
    // Disable tapping once this user has voted
    final canVote = !hasVoted;

    final Color linkedinGray = Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Metadata
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.poll_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    poll.question,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          // Sender attribution
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: RichText(
              text: TextSpan(
                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                children: [
                  TextSpan(
                    text: isMe ? 'You ' : '${poll.sender} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: 'created this poll'),
                ],
              ),
            ),
          ),

          // Options
          ...List.generate(poll.options.length, (i) {
            final votes = poll.votes.length > i ? poll.votes[i] : 0;
            final pct = total > 0 ? votes / total : 0.0;
            final isChosen = poll.localVotedIndex == i;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: InkWell(
                onTap: canVote ? () => _handleVote(i) : null,
                borderRadius: BorderRadius.circular(32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: isChosen ? colorScheme.primary : colorScheme.outlineVariant, width: isChosen ? 2 : 1),
                  ),
                  child: Stack(
                    children: [
                      // Voted Progress Bar (fills from left) — shown when any votes exist
                      if (showResults)
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isChosen ? colorScheme.primary.withValues(alpha: 0.15) : linkedinGray,
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),

                      // Option Content
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            // Radio-like circle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isChosen ? colorScheme.primary : colorScheme.outline, width: isChosen ? 6 : 1.5),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Option text
                            Expanded(
                              child: Text(
                                poll.options[i],
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                                  color: isChosen ? colorScheme.primary : colorScheme.onSurface,
                                ),
                              ),
                            ),

                            // Percentage — shown when any votes exist
                            if (showResults)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  '${(pct * 100).round()}%',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isChosen ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  total > 0 ? '$total vote${total == 1 ? '' : 's'}' : (canVote ? 'Tap an option to vote' : 'Waiting for votes…'),
                  style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (hasVoted) Icon(Icons.check_circle_outline_rounded, size: 16, color: colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Poll Sheet ────────────────────────────────────────────────────────

class _CreatePollSheet extends StatefulWidget {
  final void Function(String question, List<String> options) onSubmit;
  const _CreatePollSheet({required this.onSubmit});

  @override
  State<_CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends State<_CreatePollSheet> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [TextEditingController(), TextEditingController()];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= 6) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[index].dispose();
      _optionCtrls.removeAt(index);
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final question = _questionCtrl.text.trim();
    final options = _optionCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (options.length < 2) return;
    widget.onSubmit(question, options);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Title
              Row(
                children: [
                  Icon(Icons.poll_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('Create a Poll', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Question field
              TextFormField(
                controller: _questionCtrl,
                decoration: InputDecoration(
                  labelText: 'Question',
                  hintText: 'Ask something…',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a question' : null,
              ),
              const SizedBox(height: 12),

              // Options
              Text('Options', style: textTheme.labelLarge?.copyWith(color: colorScheme.outline)),
              const SizedBox(height: 8),
              ...List.generate(_optionCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionCtrls[i],
                          decoration: InputDecoration(
                            hintText: 'Option ${i + 1}',
                            filled: true,
                            fillColor: colorScheme.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          validator: (v) => (i < 2 && (v == null || v.trim().isEmpty)) ? 'Required' : null,
                        ),
                      ),
                      if (_optionCtrls.length > 2) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: colorScheme.error,
                          tooltip: 'Remove',
                          onPressed: () => _removeOption(i),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              // Add option button
              if (_optionCtrls.length < 6)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Option'),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                ),

              const SizedBox(height: 16),

              // Submit
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send Poll'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

