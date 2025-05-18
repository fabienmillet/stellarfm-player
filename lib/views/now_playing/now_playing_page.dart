import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../services/api_service.dart';
import '../../widgets/player_controls.dart';
import '../../widgets/playback_progress.dart';

class NowPlayingPage extends StatefulWidget {
  final String platform;

  const NowPlayingPage({super.key, required this.platform});

  @override
  NowPlayingPageState createState() => NowPlayingPageState();
}

class NowPlayingPageState extends State<NowPlayingPage> {
  String title = "Chargement...";
  String artist = "";
  String coverUrl = "";
  String nextTitle = "";
  String nextArtist = "";
  String streamUrl = "";

  int elapsed = 0;
  int duration = 0;

  bool isPlaying = false;

  final AudioPlayer _player = AudioPlayer();
  Timer? _refreshTimer;
  Timer? _progressTimer;

  String _getCoverUrl() {
    if (kIsWeb && coverUrl.isNotEmpty) {
      return 'https://corsproxy.io/?$coverUrl';
    }
    return coverUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Auto refresh from API every 20s
    _refreshTimer = Timer.periodic(Duration(seconds: 20), (_) => _fetchData());
  }

  void _fetchData() async {
    final nowPlaying = await ApiService.fetchNowPlaying();
    if (nowPlaying != null) {
      _progressTimer?.cancel();

      setState(() {
        title = nowPlaying.title;
        artist = nowPlaying.artist;
        coverUrl = nowPlaying.coverUrl;
        nextTitle = nowPlaying.nextTitle;
        nextArtist = nowPlaying.nextArtist;
        streamUrl = nowPlaying.streamUrl;
        elapsed = nowPlaying.elapsed;
        duration = nowPlaying.duration;
      });

      // Lancer le timer de progression locale
      _progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!mounted) return;

        setState(() {
          if (elapsed < duration) {
            elapsed++;
          } else {
            timer.cancel();
            _fetchData(); // 🔁 Re-fetch quand terminé
          }
        });
      });
    }
  }

  void _togglePlayback() async {
    if (isPlaying) {
      await _player.pause();
    } else if (streamUrl.isNotEmpty) {
      await _player.play(UrlSource(streamUrl));
    }

    setState(() => isPlaying = !isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    _refreshTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  Widget _buildContent() {
    final trackInfo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (coverUrl.isNotEmpty)
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
          onPlayPause: _togglePlayback,
          onRefresh: _fetchData,
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

    final background = coverUrl.isNotEmpty
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
  }

  Widget _buildTitleBar() {
    return WindowTitleBarBox(
      child: Container(
        height: 40,
        color: Colors.black.withAlpha((0.85 * 255).toInt()),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "StellarFM",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
            MinimizeWindowButton(),
            MaximizeWindowButton(),
            CloseWindowButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    switch (widget.platform) {
      case 'cupertino':
        return CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          navigationBar: CupertinoNavigationBar(
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
                _buildTitleBar(), // ✅ Réutilisation propre
                Expanded(child: _buildContent()),
              ],
            ),
          );


      default: // material
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              _buildTitleBar(),
              Expanded(child: content),
            ],
          ),
        );
    }
  }
}
