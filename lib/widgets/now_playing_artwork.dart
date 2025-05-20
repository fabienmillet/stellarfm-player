import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NowPlayingArtwork extends StatelessWidget {
  final String coverUrl;

  const NowPlayingArtwork({super.key, required this.coverUrl});

  String _getCoverUrl() {
    // Pour forcer l’utilisation de ton proxy CORS si on est sur web
    if (kIsWeb) {
      return 'https://api.stellarfm.fr/getpic';
    }
    return coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getCoverUrl();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 180,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, size: 64, color: Colors.white24),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
