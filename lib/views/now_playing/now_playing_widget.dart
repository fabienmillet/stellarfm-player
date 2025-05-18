import 'package:flutter/material.dart';

class NowPlayingWidget extends StatelessWidget {
  final String title;
  final String artist;
  final String coverUrl;

  const NowPlayingWidget({
    super.key,
    required this.title,
    required this.artist,
    required this.coverUrl,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (coverUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(coverUrl, width: 300),
          )
        else
          Icon(Icons.music_note, size: 120, color: Colors.grey[600]),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          artist,
          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
        ),
      ],
    );
  }
}
