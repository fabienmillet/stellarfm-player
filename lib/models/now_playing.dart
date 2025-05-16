class NowPlaying {
  final String title;
  final String artist;
  final String coverUrl;
  final String nextTitle;
  final String nextArtist;
  final String streamUrl;

  NowPlaying({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.nextTitle,
    required this.nextArtist,
    required this.streamUrl,
  });

  factory NowPlaying.fromApiJson(Map<String, dynamic> json) {
    final now = json['now_playing']['song'];
    final next = json['playing_next']['song'];
    final stream = json['station']['listen_url']; 

    return NowPlaying(
      title: now['title'] ?? '',
      artist: now['artist'] ?? '',
      coverUrl: now['art'] ?? '',
      nextTitle: next['title'] ?? '',
      nextArtist: next['artist'] ?? '',
      streamUrl: stream ?? '',
    );
  }
}
