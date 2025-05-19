import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class StellarAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  StellarAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  /// Appelé à chaque nouveau morceau détecté
  Future<void> playStream({
    required String url,
    required String title,
    required String artist,
    required String coverUrl,
  }) async {
    try {
      // 💡 D'abord les métadonnées (certains OS ne les affichent que si déjà en place avant lecture)
      updateMetadata(
        url: url,
        title: title,
        artist: artist,
        coverUrl: coverUrl,
      );

      if (_currentUrl != url || !_player.playing) {
        _currentUrl = url;
        await _player.setUrl(url);
        await Future.delayed(const Duration(milliseconds: 300));
        await _player.play();
      }
    } catch (e) {
      log("Erreur de lecture : $e");
    }
  }

  void updateMetadata({
    required String url,
    required String title,
    required String artist,
    required String coverUrl,
  }) {
    mediaItem.add(
      MediaItem(
        id: "$url-${DateTime.now().millisecondsSinceEpoch}", // Force le refresh iOS
        album: "StellarFM",
        title: title,
        artist: artist,
        artUri: Uri.parse(
          coverUrl.isNotEmpty
              ? coverUrl
              : "https://radio.stellarfm.fr/static/logo.png",
        ),
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [1, 3],
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
    );
  }
}

Future<AudioHandler> initAudioHandler() async {
  return await AudioService.init(
    builder: () => StellarAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'fr.stellarfm.radio.channel.audio',
      androidNotificationChannelName: 'StellarFM Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidResumeOnClick: true,
      preloadArtwork: true,
    ),
  );
}
