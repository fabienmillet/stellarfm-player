import 'package:flutter/material.dart';

class PlaybackProgress extends StatelessWidget {
  final int elapsed;
  final int duration;

  const PlaybackProgress({
    super.key,
    required this.elapsed,
    required this.duration,
  });


  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration > 0 ? elapsed / duration : 0.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600), // ✅ limite max largeur
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(elapsed),
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              Text(formatDuration(duration),
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
