import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NowPlaying {
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final String nextTitle;
  final String nextArtist;
  final String streamUrl;
  final int elapsed;
  final int duration;

  NowPlaying({
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.nextTitle,
    required this.nextArtist,
    required this.streamUrl,
    required this.elapsed,
    required this.duration,
  });

  /// Méthode utilitaire pour récupérer le vrai lien depuis https://api.stellarfm.fr/getpic
  static Future<String> _fetchCoverFromProxy() async {
    try {
      final response = await http.get(Uri.parse('https://api.stellarfm.fr/getpic'));
      if (response.statusCode == 200) {
        final body = response.body;
        final regex = RegExp(r'https:\/\/i\.scdn\.co\/image\/[a-zA-Z0-9]+');
        final match = regex.firstMatch(body);
        return match?.group(0) ?? '';
      }
    } catch (_) {}
    return '';
  }

  static Future<NowPlaying> fromApiJson(Map<String, dynamic> json) async {
    final now = json['now_playing'];
    final song = now['song'];
    final next = json['playing_next']['song'];
    final stream = json['station']['listen_url'];

    final customFields = song['custom_fields'];
    String? spotifyImage;

    if (customFields is Map<String, dynamic>) {
      final rawSpotifyImage = customFields['spotify_image'];
      if (rawSpotifyImage is String && rawSpotifyImage.isNotEmpty) {
        spotifyImage = rawSpotifyImage;
      }
    }

    final rawArt = song['art'] ?? '';
    String cover = '';

    if (spotifyImage != null) {
      cover = spotifyImage;
    } else if (kIsWeb && rawArt.toString().contains('/api/station/')) {
      cover = await _fetchCoverFromProxy();
    } else {
      cover = rawArt;
    }

    return NowPlaying(
      title: song['title'] ?? '',
      artist: song['artist'] ?? '',
      album: song['album'] ?? '',
      coverUrl: cover,
      nextTitle: next['title'] ?? '',
      nextArtist: next['artist'] ?? '',
      streamUrl: stream ?? '',
      elapsed: now['elapsed'] ?? 0,
      duration: now['duration'] ?? 0,
    );
  }
}