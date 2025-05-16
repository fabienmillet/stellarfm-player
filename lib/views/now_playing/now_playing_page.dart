import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/player_controls.dart';
import 'now_playing_widget.dart';

class NowPlayingPage extends StatefulWidget {
    final String platform; // 'material', 'cupertino', 'fluent'

    const NowPlayingPage({required this.platform});

    @override
    _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
    String title = "Chargement...";
    String artist = "";
    String coverUrl = "";
    String nextTitle = "";
    String nextArtist = "";
    String streamUrl = "";
    Timer? _refreshTimer;

    bool isPlaying = false;
    final AudioPlayer _player = AudioPlayer();

    @override
    void initState() {
        super.initState();
        _fetchData();

        // Démarrage du refresh auto toutes les 15 secondes
        _refreshTimer = Timer.periodic(
            Duration(seconds: 15),
            (timer) => _fetchData(),
        );
    }

    void _fetchData() async {
        final nowPlaying = await ApiService.fetchNowPlaying();
        if (nowPlaying != null) {
            setState(() {
                title = nowPlaying.title;
                artist = nowPlaying.artist;
                coverUrl = nowPlaying.coverUrl;
                nextTitle = nowPlaying.nextTitle;
                nextArtist = nowPlaying.nextArtist;
                streamUrl = nowPlaying.streamUrl;
            });
        }
    }

    void _togglePlayback() async {
        if (isPlaying) {
            await _player.pause();
        } else {
            if (streamUrl.isNotEmpty) {
                await _player.play(UrlSource(streamUrl));
            }
        }

        setState(() {
            isPlaying = !isPlaying;
        });
    }

    @override
    void dispose() {
        _player.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final trackInfo = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // ✅ Pochette visible uniquement ici
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

                // ✅ Infos track seulement : plus de cover ici
                Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                    ),
                ),
                Text(
                    artist,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                    ),
                ),

                const SizedBox(height: 30),
                PlayerControls(
                    isPlaying: isPlaying,
                    onPlayPause: _togglePlayback,
                    onRefresh: _fetchData,
                ),
                const SizedBox(height: 30),
                Text(
                    "🎶 À suivre :",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                    "$nextTitle – $nextArtist",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
            ],
        );

        Widget backgroundBlurLayer = coverUrl.isNotEmpty
                ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.darken,
                            ),
                            child: Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                            ),
                        ),
                    )
                : Container(color: Colors.black);

        final content = Stack(
            fit: StackFit.expand,
            children: [
                backgroundBlurLayer,
                Center(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: trackInfo,
                        ),
                    ),
                ),
            ],
        );

        // UI selon plateforme
        switch (widget.platform) {
            case 'cupertino':
            return CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                navigationBar: CupertinoNavigationBar(
                backgroundColor: Colors.transparent, // ✅ fond transparent
                border: null,                         // ✅ supprime la bordure du bas
                middle: Text(
                    "StellarFM",
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    ),
                ),
                ),
                child: content,
            );

            case 'fluent':
                return fluent.NavigationView(
                    content: fluent.ScaffoldPage(
                        header: fluent.PageHeader(title: Text('StellarFM')),
                        content: content,
                    ),
                );

            default: // Material
                return Scaffold(
                    backgroundColor: Colors.black, // pour éviter un flash blanc
                    body: SafeArea(child: content),
                );
        }
    }
}
