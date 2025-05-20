import 'dart:developer';
import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRefresh;
  final bool isLoading;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRefresh,
    required this.isLoading,
  });


  @override
  Widget build(BuildContext context) {
    log('PlayerControls rebuild → isLoading: $isLoading, isPlaying: $isPlaying');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: isLoading ? null : onPlayPause,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.3 * 255).toInt()),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: AnimatedOpacity(
                  opacity: isLoading ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
