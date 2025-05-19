import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NowPlayingController extends ChangeNotifier {
  String title = "Chargement...";
  String artist = "";
  String coverUrl = "";
  String nextTitle = "";
  String nextArtist = "";
  String streamUrl = "";

  int elapsed = 0;
  int duration = 0;

  Timer? _refreshTimer;
  Timer? _progressTimer;

  /// Callback à appeler quand une nouvelle chanson est détectée
  void Function(String title, String artist, String coverUrl, String streamUrl)? onTrackChanged;

  /// Lancer la récupération automatique
  void start() {
    _fetchNowPlaying();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) => _fetchNowPlaying());
  }

  void stop() {
    _refreshTimer?.cancel();
    _progressTimer?.cancel();
  }

  Future<void> _fetchNowPlaying() async {
    final nowPlaying = await ApiService.fetchNowPlaying();
    if (nowPlaying != null) {
      final oldTitle = title;
      final oldArtist = artist;

      _progressTimer?.cancel();

      title = nowPlaying.title;
      artist = nowPlaying.artist;
      coverUrl = nowPlaying.coverUrl;
      nextTitle = nowPlaying.nextTitle;
      nextArtist = nowPlaying.nextArtist;
      streamUrl = nowPlaying.streamUrl;
      elapsed = nowPlaying.elapsed;
      duration = nowPlaying.duration;

      notifyListeners();

      // ✅ Détection de changement
      if ((title != oldTitle || artist != oldArtist) && onTrackChanged != null) {
        onTrackChanged!(title, artist, coverUrl, streamUrl);
      }

      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (elapsed < duration) {
          elapsed++;
          notifyListeners();
        } else {
          timer.cancel();
          _fetchNowPlaying(); // re-fetch
        }
      });
    }
  }
}
