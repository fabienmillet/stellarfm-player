import 'package:flutter/material.dart';
import 'package:stellarfm_player/widgets/playback_progress.dart';
import 'package:stellarfm_player/widgets/player_controls.dart';

class NowPlayingInfo extends StatelessWidget {
  final String title;
  final String artist;
  final String nextTitle;
  final String nextArtist;
  final String coverUrl;
  final int elapsed;
  final int duration;
  final VoidCallback onPlayPause;
  final VoidCallback onRefresh;
  final bool isPlaying;
  final bool isLoading;

  const NowPlayingInfo({
    super.key,
    required this.title,
    required this.artist,
    required this.nextTitle,
    required this.nextArtist,
    required this.coverUrl,
    required this.elapsed,
    required this.duration,
    required this.onPlayPause,
    required this.onRefresh,
    required this.isPlaying,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (coverUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              coverUrl,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          artist,
          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
        ),
        const SizedBox(height: 30),
        PlaybackProgress(elapsed: elapsed, duration: duration),
        const SizedBox(height: 20),
        PlayerControls(
          isPlaying: isPlaying,
          onPlayPause: onPlayPause,
          onRefresh: onRefresh,
          isLoading: isLoading,
        ),
        const SizedBox(height: 30),
        const Text("🎶 À suivre :", style: TextStyle(fontSize: 16, color: Colors.white)),
        Text(
          "$nextTitle – $nextArtist",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[300]),
        ),
      ],
    );
  }
}
