import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../common/presentation/permission_cubit.dart';
import '../../../../../common_widgets/permission_denied_dialog_widget.dart';

class VoiceTabWidget extends StatefulWidget {
  final bool isTablet;
  final Function(String) onVoiceResult;
  final Function(String, {bool isError}) showSnackBarMessage;

  const VoiceTabWidget({
    super.key,
    required this.isTablet,
    required this.onVoiceResult,
    required this.showSnackBarMessage,
  });

  @override
  State<VoiceTabWidget> createState() => _VoiceTabWidgetState();
}

class _VoiceTabWidgetState extends State<VoiceTabWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  double _confidence = 1.0;

  static const double _spacing4 = 16.0;
  static const double _spacing6 = 24.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _startListening() async {
    final permissionCubit = context.read<PermissionCubit>();
    final status = await permissionCubit.requestMicrophonePermission();
    
    if (status != PermissionStatus.granted) {
      if (permissionCubit.shouldShowMicrophoneDialog(status)) {
        if (mounted) {
          PermissionDeniedDialogWidget.show(
            context: context,
            permissionType: 'Microphone',
          );
        }
      }
      return;
    }

    await _initSpeech();
    
    if (!_speech.isAvailable) {
      if (mounted) {
        widget.showSnackBarMessage(
          'Speech recognition not available',
          isError: true,
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _voiceText = result.recognizedWords;
          _confidence = result.confidence;
        });
        
        if (result.finalResult && _voiceText.isNotEmpty) {
          widget.onVoiceResult(_voiceText);
          _stopListening();
        }
      },
      localeId: _getLocaleId(),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  String _getLocaleId() {
    try {
      final locale = Localizations.localeOf(context);
      switch (locale.languageCode) {
        case 'fr':
          return 'fr_FR';
        case 'es':
          return 'es_ES';
        default:
          return 'en_US';
      }
    } catch (e) {
      return 'en_US';
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _clearVoiceText() {
    setState(() {
      _voiceText = '';
      _confidence = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Voice input info card
        Container(
          padding: const EdgeInsets.all(_spacing6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    size: 28,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  HeadlineSmallText(
                    'Voice Input',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BodyMediumText(
                'Speak your math problem and let AI solve it for you',
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: _spacing6),

        // Voice text display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(_spacing4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _isListening 
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: _isListening ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening 
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LabelLargeText(
                      _isListening 
                        ? 'Listening...'
                        : 'Voice Result',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_voiceText.isNotEmpty && !_isListening)
                    IconButton(
                      onPressed: _clearVoiceText,
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      tooltip: AppLocalizations.of(context)!.cancel,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_voiceText.isNotEmpty)
                BodyLargeText(
                  _voiceText,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              else
                Text(
                  _isListening 
                    ? 'Speak now...'
                    : 'Tap to speak',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (_isListening && _voiceText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    LabelSmallText(
                      'Confidence: ${(_confidence * 100).round()}%',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: _spacing6),

        // Voice control buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : _startListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening 
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: _isListening
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? 'Stop' : 'Start Listening'),
              ),
            ),
            const SizedBox(width: _spacing4),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _voiceText.isNotEmpty && !_isListening
                  ? () => widget.onVoiceResult(_voiceText)
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.psychology),
                label: Text(AppLocalizations.of(context)!.solve),
              ),
            ),
          ],
        ),

        const SizedBox(height: _spacing4),

        // Voice tips
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabelMediumText(
                  'Speak clearly and pause briefly after stating your math problem',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}