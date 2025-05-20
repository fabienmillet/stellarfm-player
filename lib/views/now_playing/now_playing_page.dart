import 'dart:ui';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../controllers/now_playing_controller.dart';
import '../../widgets/now_playing_info.dart';
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

  bool _isLoading = false;
  bool _isPlaying = false;

  StellarAudioHandler get _stellarHandler =>
      widget.audioHandler as StellarAudioHandler;

  @override
  void initState() {
    super.initState();

    _stellarHandler.player.playerStateStream.listen((state) {
      final isActuallyPlaying = state.playing &&
          state.processingState == ProcessingState.ready;

      if (mounted) {
        setState(() {
          _isPlaying = isActuallyPlaying;
          if (isActuallyPlaying) _isLoading = false;
        });
      }
    });

    controller.onTrackChanged = (title, artist, coverUrl, url) {
      if (_isPlaying) {
        _stellarHandler.playStream(
          url: url,
          title: title,
          artist: artist,
          coverUrl: coverUrl,
        );
      } else {
        _stellarHandler.updateMetadata(
          url: url,
          title: title,
          artist: artist,
          coverUrl: coverUrl,
        );
      }
    };

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
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final playbackState = await widget.audioHandler.playbackState.first;

    if (playbackState.playing) {
      await widget.audioHandler.pause();
    } else if (controller.streamUrl.isNotEmpty) {
      await _stellarHandler.playStream(
        url: controller.streamUrl,
        title: controller.title,
        artist: controller.artist,
        coverUrl: controller.coverUrl,
      );
    }
    } catch (e, stack) {
      log("Erreur lecture/pause", error: e, stackTrace: stack, name: 'NowPlaying');
    } finally {
      setState(() => _isLoading = false); // 👈 FIN DU LOADER GARANTIE
    }
  }

  String get coverUrl {
  if (kIsWeb) {
    return 'https://api.stellarfm.fr/getpic';
  }
  return controller.coverUrl;
}

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final trackInfo = NowPlayingInfo(
          title: controller.title,
          artist: controller.artist,
          nextTitle: controller.nextTitle,
          nextArtist: controller.nextArtist,
          coverUrl: controller.coverUrl,
          elapsed: controller.elapsed,
          duration: controller.duration,
          isPlaying: _isPlaying,
          isLoading: _isLoading,
          onPlayPause: _togglePlayback,
          onRefresh: controller.start,
        );

        final background = controller.coverUrl.isNotEmpty
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withAlpha((0.4 * 255).toInt()), BlendMode.darken),
                  child: Image.network(
                    controller.coverUrl,
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
