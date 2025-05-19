import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../controllers/now_playing_controller.dart';
import '../../widgets/player_controls.dart';
import '../../widgets/playback_progress.dart';
import '../../widgets/now_playing_title_bar.dart';
import 'package:stellarfm_player/audio/audio_handler.dart';

class NowPlayingPage extends StatefulWidget {
  final String platform;
  final AudioHandler audioHandler;

  const NowPlayingPage({
    super.key,
    required this.platform,
    required this.audioHandler,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final controller = NowPlayingController();

  StellarAudioHandler get _stellarHandler =>
      widget.audioHandler as StellarAudioHandler;

  @override
  void initState() {
    super.initState();

    controller.onTrackChanged = (title, artist, coverUrl, url) {
      _stellarHandler.playStream(
        url: url,
        title: title,
        artist: artist,
        coverUrl: coverUrl,
      );
    };

    // ✅ Donne 100ms de "respiration" au framework pour que les handlers soient prêts
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.start();
    });
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  void _togglePlayback() async {
    final state = await widget.audioHandler.playbackState.first;

    if (state.playing) {
      await widget.audioHandler.pause();
    } else if (controller.streamUrl.isNotEmpty) {
      await _stellarHandler.playStream(
        url: controller.streamUrl,
        title: controller.title,
        artist: controller.artist,
        coverUrl: controller.coverUrl,
      );
    }
  }

  String _getCoverUrl() {
    if (kIsWeb && controller.coverUrl.isNotEmpty) {
      return 'https://corsproxy.io/?${controller.coverUrl}';
    }
    return controller.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final trackInfo = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.coverUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _getCoverUrl(),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 30),
            Text(
              controller.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              controller.artist,
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
            const SizedBox(height: 30),
            PlaybackProgress(elapsed: controller.elapsed, duration: controller.duration),
            const SizedBox(height: 20),
            StreamBuilder<PlaybackState>(
              stream: widget.audioHandler.playbackState,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return PlayerControls(
                  isPlaying: playing,
                  onPlayPause: _togglePlayback,
                  onRefresh: controller.start,
                );
              },
            ),
            const SizedBox(height: 30),
            const Text("🎶 À suivre :", style: TextStyle(fontSize: 16, color: Colors.white)),
            Text(
              "${controller.nextTitle} – ${controller.nextArtist}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),
          ],
        );

        final background = controller.coverUrl.isNotEmpty
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.4 * 255).toInt()), BlendMode.darken),
                  child: Image.network(
                    _getCoverUrl(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              )
            : Container(color: Colors.black);

        return Stack(
          fit: StackFit.expand,
          children: [
            background,
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: trackInfo,
              ),
            ),
          ],
        );
      },
    );

    switch (widget.platform) {
      case 'cupertino':
        return CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Colors.transparent,
            border: null,
            middle: Text(
              "StellarFM",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          child: content,
        );

      case 'fluent':
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              const NowPlayingTitleBar(),
              Expanded(child: content),
            ],
          ),
        );

      default:
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              const NowPlayingTitleBar(),
              Expanded(child: content),
            ],
          ),
        );
    }
  }
}
