import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class StellarAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;
  AudioPlayer get player => _player;

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

      // 🔁 Ajoute ce bloc pour observer les états
      _player.playerStateStream.listen((state) {
        log('[JUST_AUDIO] processing=${state.processingState}, playing=${state.playing}');
      });

    } catch (e, stack) {
      log('Erreur dans playStream()', error: e, stackTrace: stack, name: 'AudioHandler');
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
  Future<void> play() async {
    try {
      // Si le flux est terminé ou inactif, on relance l'URL actuelle
      if (_player.processingState == ProcessingState.completed ||
          _player.processingState == ProcessingState.idle ||
          (_player.processingState == ProcessingState.ready && !_player.playing)) {
        if (_currentUrl != null) {
          await _player.setUrl(_currentUrl!);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      await _player.play();
    } catch (e) {
      log("Erreur lors de la reprise de la lecture : $e");
    }
  }


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
