import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/conversation_message.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/conversation_controller.dart';
import '../../../clinical_summary/presentation/controllers/summary_controller.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  bool _isGeneratingSummary = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? textToSend]) {
    final text = textToSend ?? _textController.text;
    if (text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    ref.read(conversationNotifierProvider.notifier).sendMessage(text: text.trim());
    _textController.clear();
    _scrollToBottom();
  }

  void _handleVoiceInput() {
    HapticFeedback.heavyImpact();
    final notifier = ref.read(conversationNotifierProvider.notifier);
    notifier.toggleVoiceInput(
      fallbackText: _textController.text,
      onLiveText: (liveText) {
        if (mounted && liveText.trim().isNotEmpty) {
          _textController.text = liveText;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        }
      },
    );
  }

  Future<void> _handleGenerateSummary() async {
    if (_isGeneratingSummary) return;
    setState(() => _isGeneratingSummary = true);
    try {
      final notifier = ref.read(conversationNotifierProvider.notifier);
      final summary = await notifier.generateSummary();
      ref.read(activeSummaryProvider.notifier).state = summary;
      if (mounted) {
        context.push('/clinical-summary');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate summary: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSummary = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final state = ref.watch(conversationNotifierProvider);
    final messages = state.conversation?.messages ?? [];
    final isIntakeComplete = state.isComplete;

    ref.listen<int>(
      conversationNotifierProvider.select((s) => s.conversation?.messages.length ?? 0),
      (prev, next) {
        if (next != prev) {
          _scrollToBottom();
        }
      },
    );

    ref.listen<String?>(
      conversationNotifierProvider.select((s) => s.error),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () => ref.read(conversationNotifierProvider.notifier).clearError(),
              ),
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 68, // Taller app bar for elderly
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 22,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.clinicalAssistant,
                    style: AppTypography.titleMedium,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.assistantStatus,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 26,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart Intake',
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(conversationNotifierProvider.notifier).initConversation();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Strip ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              color: AppColors.primaryContainer.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Information collection only • Not a medical diagnosis',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isIntakeComplete)
                        GestureDetector(
                          onTap: _isGeneratingSummary ? null : _handleGenerateSummary,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isGeneratingSummary
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Summary ➤',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.completenessScore,
                            backgroundColor: AppColors.primaryContainer,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isIntakeComplete ? AppColors.success : AppColors.primary,
                            ),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(state.completenessScore * 100).round()}%',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phaseLabel(state.currentPhase),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Chat Messages ────────────────────────────────────────────
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Preparing your consultation...',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: messages.length + (state.isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && state.isAiTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(messages[index]);
                      },
                    ),
            ),

            // ── Voice Recording Banner ───────────────────────────────────
            if (state.isListening)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 30),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.liveTranscribedText.isNotEmpty
                                    ? state.liveTranscribedText
                                    : 'Listening...',
                                style: AppTypography.titleSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                state.liveTranscribedText.isNotEmpty
                                    ? 'Tap Done to send this message'
                                    : 'Speak clearly, then tap Done',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleVoiceInput,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Done',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // ── Quick Suggestions ────────────────────────────────────────
            if (state.currentSuggestions.isNotEmpty && !state.isAiTyping)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.currentSuggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final suggestion = state.currentSuggestions[index];
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      onPressed: () => _sendMessage(suggestion),
                    );
                  },
                ),
              ),

            // ── Summary CTA ──────────────────────────────────────────────
            if (isIntakeComplete)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppButton(
                  text: 'Generate Clinical Intake Summary',
                  icon: Icons.assignment_turned_in_rounded,
                  height: 60,
                  isLoading: _isGeneratingSummary,
                  onPressed: _handleGenerateSummary,
                ),
              ),

            // ── Input Bar ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.attach_file_rounded, size: 24),
                      color: AppColors.textSecondary,
                      onPressed: () => context.push('/upload-record'),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: AppTypography.bodyMedium,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Type or use mic...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (v) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── BIG MIC BUTTON ───────────────────────────────────
                  GestureDetector(
                    onTap: _handleVoiceInput,
                    child: state.isListening
                        ? AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ripple ring
                                  Container(
                                    width: 72 * _rippleAnimation.value,
                                    height: 72 * _rippleAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.error.withValues(
                                        alpha: 0.3 * (1 - (_rippleAnimation.value - 0.8) / 0.6),
                                      ),
                                    ),
                                  ),
                                  // Core button
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.error.withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.stop_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(13, 148, 136, 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),

                  // Send button
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 24),
                      color: Colors.white,
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    final isPatient = message.role == MessageRole.patient;
    final isSystem = message.role == MessageRole.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF7F1D1D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text(
                  'Call 112 / 108 Emergency',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Emergency Services 112...')),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isPatient) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.health_and_safety_rounded,
                  size: 20, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isPatient ? AppColors.primary : AppColors.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isPatient ? 20 : 4),
                  bottomRight: Radius.circular(isPatient ? 4 : 20),
                ),
                border: isPatient
                    ? null
                    : Border.all(color: AppColors.aiBubbleBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(15, 23, 42, 0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.isVoice)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_rounded,
                            size: 14,
                            color: isPatient ? Colors.white70 : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Transcribed Speech',
                            style: AppTypography.labelSmall.copyWith(
                              color: isPatient ? Colors.white70 : AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isPatient ? Colors.white : AppColors.textPrimary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatTime(message.timestamp),
                    style: AppTypography.labelSmall.copyWith(
                      color: isPatient ? Colors.white60 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPatient) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.health_and_safety_rounded,
                size: 20, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.aiBubbleBorder, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Assistant is thinking...',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'CHIEF_COMPLAINT':
        return 'Stage: Chief Complaint';
      case 'SOCRATES':
        return 'Stage: History of Presenting Illness';
      case 'MEDICAL_HISTORY':
        return 'Stage: Medical History';
      case 'AYUSH_ASSESSMENT':
        return 'Stage: Ayurvedic Assessment';
      case 'REVIEW_OF_SYSTEMS':
        return 'Stage: Review of Systems';
      case 'COMPLETE':
        return '✅ Intake Complete — Ready for Summary';
      default:
        return 'Stage: $phase';
    }
  }
}
