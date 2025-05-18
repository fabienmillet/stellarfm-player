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

  factory NowPlaying.fromApiJson(Map<String, dynamic> json) {
    final now = json['now_playing'];
    final song = now['song'];
    final next = json['playing_next']['song'];
    final stream = json['station']['listen_url'];

    return NowPlaying(
      title: song['title'] ?? '',
      artist: song['artist'] ?? '',
      album: song['album'] ?? '',
      coverUrl: song['art'] ?? '',
      nextTitle: next['title'] ?? '',
      nextArtist: next['artist'] ?? '',
      streamUrl: stream ?? '',
      elapsed: now['elapsed'] ?? 0,
      duration: now['duration'] ?? 0,
    );
  }
}
