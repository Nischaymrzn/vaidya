import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/intelligence/presentation/models/vaidya_care_doctor_profile.dart';
import 'package:vaidya/features/intelligence/presentation/state/vaidya_care_state.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/vaidya_care_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class VaidyaCareConsultScreen extends ConsumerStatefulWidget {
  final String doctorId;

  const VaidyaCareConsultScreen({super.key, required this.doctorId});

  @override
  ConsumerState<VaidyaCareConsultScreen> createState() =>
      _VaidyaCareConsultScreenState();
}

class _VaidyaCareConsultScreenState
    extends ConsumerState<VaidyaCareConsultScreen> {
  final ScrollController _transcriptController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechSupported = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _interimText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref
          .read(vaidyaCareViewModelProvider.notifier)
          .startConsult(doctorId: widget.doctorId);
      await _initializeVoice();
    });
  }

  Future<void> _initializeVoice() async {
    try {
      final supported = await _speechToText.initialize(
        onStatus: (status) {
          final lowered = status.toLowerCase();
          if (lowered.contains('done') || lowered.contains('notlistening')) {
            if (mounted) {
              setState(() => _isListening = false);
            }
            _resumeListeningIfNeeded();
          }
        },
        onError: (_) {
          if (!mounted) return;
          setState(() => _isListening = false);
        },
      );

      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.54);
      await _flutterTts.setPitch(0.9);
      await _flutterTts.setVolume(1.0);
      await _applyDoctorMaleVoice();

      _flutterTts.setStartHandler(() async {
        if (!mounted) return;
        setState(() => _isSpeaking = true);
        await _stopListening();
      });
      _flutterTts.setCompletionHandler(() {
        if (!mounted) return;
        setState(() => _isSpeaking = false);
        _resumeListeningIfNeeded();
      });
      _flutterTts.setErrorHandler((_) {
        if (!mounted) return;
        setState(() => _isSpeaking = false);
        _resumeListeningIfNeeded();
      });

      if (!mounted) return;
      setState(() => _speechSupported = supported);
      _resumeListeningIfNeeded();
    } catch (_) {
      if (!mounted) return;
      setState(() => _speechSupported = false);
    }
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final vm = ref.read(vaidyaCareViewModelProvider.notifier);
    vm.toggleMic();
    final micOn = ref.read(vaidyaCareViewModelProvider).micOn;
    if (!micOn) {
      await _stopListening();
      if (mounted) {
        setState(() => _interimText = '');
      }
      return;
    }
    _resumeListeningIfNeeded();
  }

  Future<void> _startListening() async {
    final state = ref.read(vaidyaCareViewModelProvider);
    if (!_speechSupported ||
        _isListening ||
        _isSpeaking ||
        !state.micOn ||
        state.isThinking) {
      return;
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
      if (!mounted) return;
      setState(() => _isListening = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (_) {
      // Ignore platform stop errors.
    }
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _interimText = result.recognizedWords.trim());
    if (!result.finalResult) return;

    final finalText = _interimText.trim();
    setState(() => _interimText = '');
    if (finalText.isEmpty) return;
    _dispatchMessage(finalText);
  }

  Future<void> _dispatchMessage(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;

    final pendingReply = ref
        .read(vaidyaCareViewModelProvider.notifier)
        .sendMessage(value);
    _scrollToBottom();
    final reply = await pendingReply;
    if (!mounted) return;

    _scrollToBottom();
    if (reply != null && reply.trim().isNotEmpty) {
      await _speak(reply.trim());
    } else {
      _resumeListeningIfNeeded();
    }
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      _resumeListeningIfNeeded();
    }
  }

  Future<void> _applyDoctorMaleVoice() async {
    try {
      final dynamic voicesRaw = await _flutterTts.getVoices;
      if (voicesRaw is! List) return;

      final voices = voicesRaw
          .whereType<Map>()
          .map(
            (voice) => voice.map(
              (key, value) => MapEntry('$key'.toLowerCase(), '$value'),
            ),
          )
          .toList();
      if (voices.isEmpty) return;

      final englishVoices = voices.where((voice) {
        final locale = (voice['locale'] ?? '').toLowerCase();
        return locale.startsWith('en');
      }).toList();
      final candidates = englishVoices.isNotEmpty ? englishVoices : voices;

      const strongMaleTokens = <String>[
        'male',
        'man',
        'daniel',
        'david',
        'thomas',
        'alex',
        'john',
        'matthew',
        'ryan',
        'guy',
        'iom',
        'iol',
      ];
      const femaleTokens = <String>[
        'female',
        'woman',
        'samantha',
        'karen',
        'zira',
        'siri',
        'tpc',
        'tpf',
        'sfg',
      ];

      Map<String, String>? selected;
      var bestScore = -999;

      for (final voice in candidates) {
        final locale = (voice['locale'] ?? '').toLowerCase();
        final name = (voice['name'] ?? '').toLowerCase();
        final identifier = (voice['identifier'] ?? '').toLowerCase();
        final gender = (voice['gender'] ?? '').toLowerCase();
        final bag = '$name $identifier';
        var score = 0;

        if (locale == 'en-us') score += 30;
        if (locale.startsWith('en')) score += 15;
        if (gender.contains('male')) score += 100;
        if (gender.contains('female')) score -= 100;

        for (final token in strongMaleTokens) {
          if (bag.contains(token)) score += 45;
        }
        for (final token in femaleTokens) {
          if (bag.contains(token)) score -= 45;
        }

        if (score > bestScore) {
          bestScore = score;
          selected = voice;
        }
      }

      final selectedName = selected?['name'];
      final selectedLocale = selected?['locale'];
      if (selectedName == null || selectedLocale == null) return;

      final selectedVoice = <String, String>{
        'name': selectedName,
        'locale': selectedLocale,
      };
      final selectedIdentifier = selected?['identifier'];
      if (selectedIdentifier != null && selectedIdentifier.isNotEmpty) {
        selectedVoice['identifier'] = selectedIdentifier;
      }
      await _flutterTts.setVoice(selectedVoice);
    } catch (_) {
      // If voice metadata isn't available on device, keep platform default.
    }
  }

  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (_) {
      // Ignore platform stop errors.
    }
    if (!mounted) return;
    setState(() => _isSpeaking = false);
    _resumeListeningIfNeeded();
  }

  void _resumeListeningIfNeeded() {
    final state = ref.read(vaidyaCareViewModelProvider);
    if (!_speechSupported || _isSpeaking || state.isThinking || !state.micOn) {
      return;
    }
    _startListening();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_transcriptController.hasClients) return;
      _transcriptController.animateTo(
        _transcriptController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  String _patientName() {
    final raw = ref.read(userSessionServiceProvider).getCurrentUserFullName();
    final value = raw?.trim() ?? '';
    return value.isEmpty ? 'Patient' : value;
  }

  String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'PT';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    ref.listen<VaidyaCareState>(vaidyaCareViewModelProvider, (prev, next) {
      final newMessage = next.messages.length != prev?.messages.length;
      if (newMessage || next.isThinking != prev?.isThinking) {
        _scrollToBottom();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                style: TextStyle(fontFamily: 'Urbanist'),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        ref.read(vaidyaCareViewModelProvider.notifier).clearMessages();
      }
    });

    final state = ref.watch(vaidyaCareViewModelProvider);
    final doctor = state.selectedDoctor;
    final patientName = _patientName();
    final patientInitials = _initials(patientName);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor: ${doctor.name}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1),
            Text(
              doctor.title,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1020;
            Widget transcript(double height) {
              return SizedBox(
                height: height,
                child: _TranscriptCard(
                  doctorName: doctor.name,
                  messages: state.messages,
                  captionsOn: state.captionsOn,
                  isThinking: state.isThinking,
                  interimText: _interimText,
                  isSpeaking: _isSpeaking,
                  micOn: state.micOn,
                  speechSupported: _speechSupported,
                  transcriptController: _transcriptController,
                  onStopSpeaking: _stopSpeaking,
                ),
              );
            }

            Widget patientScreen() {
              return _PatientCameraCard(
                patientName: patientName,
                patientInitials: patientInitials,
                cameraOn: state.cameraOn,
                shareOn: state.shareOn,
                micOn: state.micOn,
                captionsOn: state.captionsOn,
                listening: _isListening,
                onToggleMic: _toggleMic,
                onToggleCamera: () => ref
                    .read(vaidyaCareViewModelProvider.notifier)
                    .toggleCamera(),
                onToggleCaptions: () => ref
                    .read(vaidyaCareViewModelProvider.notifier)
                    .toggleCaptions(),
                onToggleShare: () => ref
                    .read(vaidyaCareViewModelProvider.notifier)
                    .toggleShare(),
              );
            }

            if (wide) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 58,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DoctorHeroCard(doctor: doctor),
                          const SizedBox(height: 12),
                          patientScreen(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 42, child: transcript(680)),
                  ],
                ),
              );
            }

            final availableHeight = constraints.maxHeight - 36;
            const minTranscriptHeight = 180.0;
            const sectionsGap = 24.0;
            double heroHeight = (availableHeight * 0.27).clamp(165.0, 220.0);
            double patientHeight = (availableHeight * 0.27).clamp(155.0, 210.0);

            final maxCombined =
                availableHeight - sectionsGap - minTranscriptHeight;
            if (heroHeight + patientHeight > maxCombined && maxCombined > 0) {
              final scale = maxCombined / (heroHeight + patientHeight);
              heroHeight *= scale;
              patientHeight *= scale;
            }
            final mobileTranscriptHeight = math.max(
              minTranscriptHeight,
              availableHeight - heroHeight - patientHeight - sectionsGap,
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: heroHeight,
                    child: _DoctorHeroCard(doctor: doctor),
                  ),
                  SizedBox(height: 12),
                  SizedBox(height: patientHeight, child: patientScreen()),
                  SizedBox(height: 12),
                  transcript(mobileTranscriptHeight),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoctorHeroCard extends StatelessWidget {
  final VaidyaCareDoctorProfile doctor;

  const _DoctorHeroCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 7.4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF12213D), Color(0xFF334B6D)],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                top: 10,
                bottom: 0,
                child: Image.asset(
                  doctor.imageAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x12000000), Color(0x77000000)],
                  ),
                ),
              ),
              Positioned(left: 12, top: 12, child: _chip(doctor.name)),
              Positioned(
                right: 12,
                top: 12,
                child: _chip(doctor.title.replaceAll(' AI Specialist', '')),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(
                      220,
                      MediaQuery.sizeOf(context).width * 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC020817),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'We can review ${doctor.focus.first} and ${doctor.focus[1]} together.',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PatientCameraCard extends StatelessWidget {
  final String patientName;
  final String patientInitials;
  final bool cameraOn;
  final bool shareOn;
  final bool micOn;
  final bool captionsOn;
  final bool listening;
  final Future<void> Function() onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleCaptions;
  final VoidCallback onToggleShare;

  const _PatientCameraCard({
    required this.patientName,
    required this.patientInitials,
    required this.cameraOn,
    required this.shareOn,
    required this.micOn,
    required this.captionsOn,
    required this.listening,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleCaptions,
    required this.onToggleShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF181B21), Color(0xFF12151A)]
              : const [Colors.white, Color(0xFFF5F7FA)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 6.2,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1E222A).withValues(alpha: 0.98),
                              const Color(0xFF171A20),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.96),
                              const Color(0xFFEFF3F8),
                            ],
                    ),
                  ),
                ),
              ),
              Positioned(left: 14, top: 14, child: _labelChip(patientName)),
              if (shareOn)
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0x1A1F7AE0),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Color(0x4D1F7AE0)),
                    ),
                    child: Text(
                      'Sharing screen',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (micOn && listening)
                Positioned(
                  left: 14,
                  bottom: 66,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0x1A1F7AE0),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Color(0x4D1F7AE0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.audioLines,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Listening...',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned.fill(
                child: Center(
                  child: cameraOn
                      ? Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.card
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            patientInitials,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0F172A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.cameraOff,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Camera off',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceSoft.withValues(alpha: 0.96)
                            : Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ControlButton(
                            active: micOn,
                            icon: micOn ? LucideIcons.mic : LucideIcons.micOff,
                            onTap: () {
                              onToggleMic();
                            },
                            color: AppColors.primary,
                            tooltip: listening ? 'Listening...' : 'Mic',
                          ),
                          SizedBox(width: 6),
                          _ControlButton(
                            active: cameraOn,
                            icon: cameraOn
                                ? LucideIcons.camera
                                : LucideIcons.cameraOff,
                            onTap: onToggleCamera,
                            color: AppColors.primary,
                            tooltip: 'Camera',
                          ),
                          SizedBox(width: 6),
                          _ControlButton(
                            active: captionsOn,
                            icon: captionsOn
                                ? LucideIcons.captions
                                : LucideIcons.captionsOff,
                            onTap: onToggleCaptions,
                            color: AppColors.primary,
                            tooltip: 'Captions',
                          ),
                          SizedBox(width: 6),
                          _ControlButton(
                            active: shareOn,
                            icon: shareOn
                                ? LucideIcons.screenShare
                                : LucideIcons.monitorOff,
                            onTap: onToggleShare,
                            color: AppColors.primary,
                            tooltip: 'Share',
                          ),
                          const SizedBox(width: 6),
                          _ControlButton(
                            active: true,
                            icon: LucideIcons.phoneOff,
                            onTap: null,
                            color: Color(0xFFE11D48),
                            tooltip: 'End',
                          ),
                        ],
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
  }

  Widget _labelChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final bool active;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final String tooltip;

  const _ControlButton({
    required this.active,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? color.withValues(alpha: 0.14)
                : (isDark ? AppColors.surfaceSoft : Colors.white),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.6) : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 17,
            color: active ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final String doctorName;
  final List<VaidyaCareMessage> messages;
  final bool captionsOn;
  final bool isThinking;
  final String interimText;
  final bool isSpeaking;
  final bool micOn;
  final bool speechSupported;
  final ScrollController transcriptController;
  final Future<void> Function() onStopSpeaking;

  const _TranscriptCard({
    required this.doctorName,
    required this.messages,
    required this.captionsOn,
    required this.isThinking,
    required this.interimText,
    required this.isSpeaking,
    required this.micOn,
    required this.speechSupported,
    required this.transcriptController,
    required this.onStopSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live transcript',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Real-time voice summary & notes',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: transcriptController,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                if (!captionsOn)
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.surfaceSoft,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Captions are off.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ...messages.map(
                  (m) => _TranscriptBubble(
                    isUser: m.isUser,
                    roleLabel: m.isUser ? 'You' : doctorName,
                    content: m.content,
                  ),
                ),
                if (captionsOn && interimText.trim().isNotEmpty)
                  _TranscriptBubble(
                    isUser: true,
                    roleLabel: 'You',
                    content: interimText.trim(),
                    muted: true,
                  ),
                if (isThinking)
                  _TranscriptBubble(
                    isUser: false,
                    roleLabel: doctorName,
                    content: 'Thinking...',
                    muted: true,
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: isSpeaking ? onStopSpeaking : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Stop speaking',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                ),
                Spacer(),
                Flexible(
                  child: Text(
                    isSpeaking
                        ? 'AI is speaking. Mic is paused.'
                        : micOn
                        ? 'Mic is on.'
                        : 'Mic is off.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!speechSupported)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.warningSurface,
                border: Border.all(
                  color: isDark
                      ? AppColors.warning.withValues(alpha: 0.35)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Text(
                'Voice recognition is not available on this device. You can still type messages.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.warning
                      : const Color(0xFF92400E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  final bool isUser;
  final String roleLabel;
  final String content;
  final bool muted;

  const _TranscriptBubble({
    required this.isUser,
    required this.roleLabel,
    required this.content,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.88,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Color(0x1A1F7AE0)
                        : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        content,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                          height: 1.32,
                          fontWeight: FontWeight.w500,
                          color: muted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

