import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';

class QuizTimerWidget extends StatelessWidget {
  final int remainingTimeInSeconds;
  final int totalTimeInMinutes;

  const QuizTimerWidget({
    super.key,
    required this.remainingTimeInSeconds,
    required this.totalTimeInMinutes,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(BuildContext context) {
    final totalSeconds = totalTimeInMinutes * 60;
    final percentageRemaining = remainingTimeInSeconds / totalSeconds;
    
    if (percentageRemaining <= 0.1) {
      return Colors.red;
    } else if (percentageRemaining <= 0.25) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalTimeInMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final timerColor = _getTimerColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: timerColor,
          ),
          const SizedBox(width: 4),
          TitleSmallText(
            _formatTime(remainingTimeInSeconds),
            fontWeight: FontWeight.w600,
            color: timerColor,
          ),
        ],
      ),
    );
  }
}