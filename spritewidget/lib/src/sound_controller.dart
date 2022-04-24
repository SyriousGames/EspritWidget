import 'dart:io';

// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
// import 'package:soundpool/soundpool.dart';

import 'simple_logger.dart';

/// Controls loading, unloading, playing, control, and management of sounds.
class SoundController {
  final log = getLogger('SoundController');

  // Music:
  // From audioplayers plugin. Yeah, AudioCache has 'assets/' hard-coded when loading the asset, so add '../' here.
  // TODO final AudioCache _audioCache = AudioCache(prefix: '../');
  Map<String, File> _musicNameToFileMap = {};
  List<SoundStreamControl> _trackedMusicStreams = [];
  bool _musicMuted = false;

  // Fx:
  // From soundpool plugin
  // TODO final Soundpool _soundpool;
  Map<String, _SoundDef> _fxNameToDefMap = {};
  List<SoundStreamControl> _trackedFxStreams = [];
  bool _fxMuted = false;

  /// [streamType] is the device audio channel for the sounds. Typically this is the "music" channel.
  // SoundController(
  //     {StreamType streamType = StreamType.music, int maxConcurrentSounds = 100})
  //     : _soundpool =
  //           Soundpool(streamType: streamType, maxStreams: maxConcurrentSounds);
  SoundController();

  /// Loads a map of sound effects (fx) files. These should be short sounds, say less than a 10 seconds.
  /// The map key is the sound "name", used to play
  /// the sound later. The value is the Flutter asset file name which must be
  /// defined in pubspec.yml.
  Future<void> loadAllFx(
      AssetBundle bundle, Map<String, String> soundNameToAssetNameMap) async {
    await Future.forEach<MapEntry<String, String>>(
        soundNameToAssetNameMap.entries, (entry) async {
      final soundName = entry.key;
      final assetName = entry.value;
      final soundData = await bundle.load(assetName);
      final soundId = 0; // TODO await _soundpool.load(soundData);
      _fxNameToDefMap[soundName] = _SoundDef(soundId, assetName);
      // log.v('Loaded fx sound $assetName as $soundName');
    });
  }

  /// Loads a map of longer sound files, e.g., music. The map key is the sound "name", used to play
  /// the sound later. The value is the Flutter asset file name which must be
  /// defined in pubspec.yml.
  Future<void> loadAllMusic(
      AssetBundle bundle, Map<String, String> soundNameToAssetNameMap) async {
    await Future.forEach<MapEntry<String, String>>(
        soundNameToAssetNameMap.entries, (entry) async {
      final soundName = entry.key;
      final assetName = entry.value;
      // TODO  final tmpFile = await _audioCache.load(assetName);
      // TODO _musicNameToFileMap[soundName] = tmpFile;
      // log.v('Loaded music sound $assetName as $soundName');
    });
  }

  /// Play a sound fx and return a SoundStreamControl to control sound playback.
  /// If soundName is not found, null is returned. If this controller is muted, nothing is played and null is returned.
  Future<SoundStreamControl?> playFx(String soundName,
      {double volume = 1.0, int repeatTimes = 0}) async {
    if (_fxMuted) {
      return null;
    }

    var soundDef = _fxNameToDefMap[soundName];
    if (soundDef == null) {
      log.e('Fx sound name "$soundName" not loaded');
      return null;
    }

    // TODO
    // await _soundpool.setVolume(soundId: soundDef.soundId, volume: volume);
    // int streamId = await _soundpool.play(soundDef.soundId, repeat: repeatTimes);

    SoundStreamControl control =
        _SoundPoolSoundStreamControl._(); // TODO _soundpool, streamId);
    _trackedFxStreams.add(control);
    return control;
  }

  /// Play a music sound and return a SoundStreamControl to control sound playback.
  /// If soundName is not found, null is returned. If this controller is muted, nothing is played and null is returned.
  Future<SoundStreamControl?> playMusic(String soundName,
      {double volume = 1.0, bool repeat = false}) async {
    if (_musicMuted) {
      return null;
    }

    var file = _musicNameToFileMap[soundName];
    if (file == null) {
      log.e('Music sound name "$soundName" not loaded');
      return null;
    }

    // TODO Upgrade AudioPlayer
    // final audioPlayer = AudioPlayer();
    // audioPlayer.setVolume(volume);
    // audioPlayer.setReleaseMode(repeat ? ReleaseMode.LOOP : ReleaseMode.RELEASE);
    // audioPlayer.setUrl(file.path, isLocal: true);
    // await audioPlayer.resume(); // Start playing.

    final control = _AudioPlaySoundStreamControl._(null); // TODO audioPlayer);
    _trackedMusicStreams.add(control);
    return control;
  }

  /// Mutes or unmutes all sound fx. When muting, currently playing sound fx are stopped and new attempting to play sound fx
  /// afterwards is ignored. Unmuting simply allows new fx to be played.
  Future<void> setFxMuteState(bool muted) async {
    _fxMuted = muted;
    if (_fxMuted) {
      await stopAllFx();
    }
  }

  /// Mutes or unmutes all music. When muting, currently playing sound fx are stopped and new attempting to play music
  /// afterwards is ignored. Unmuting simply allows new music to be played.
  Future<void> setMusicMuteState(bool muted) async {
    _musicMuted = muted;
    if (_musicMuted) {
      await stopAllMusic();
    }
  }

  /// Stops all tracked sound streams.
  Future<void> stopAll() {
    return Future.wait([stopAllFx(), stopAllMusic()]);
  }

  /// Pauses all tracked sound streams. They may be resumed with `resumeAll()`, or individual with `SoundStreamControl.resume()`.
  Future<void> pauseAll() {
    return Future.wait([pauseAllFx(), pauseAllMusic()]);
  }

  /// Resumes all tracked sound streams that had been previously paused.
  Future<void> resumeAll() {
    return Future.wait([resumeAllFx(), resumeAllMusic()]);
  }

  /// Unloads all previously loaded sounds. You won't be able to play more sounds unless you load it first.
  Future<void> unloadAll() {
    return Future.wait([unloadAllFx(), unloadAllMusic()]);
  }

  /// Disposes of this controller, releasing any system resources.
  Future<void> dispose() async {
    await unloadAll();
    // TODO return _soundpool.dispose();
  }

  /// Stops all tracked fx streams.
  Future<void> stopAllFx() async {
    await Future.forEach<SoundStreamControl>(
        _trackedFxStreams, (stream) => stream.stop());
    _trackedFxStreams.clear();
  }

  /// Stops all tracked music streams.
  Future<void> stopAllMusic() async {
    await Future.forEach<SoundStreamControl>(
        _trackedMusicStreams, (stream) => stream.stop());
    _trackedMusicStreams.clear();
  }

  /// Pauses all tracked fx streams. They may be resumed with `resumeAll()`, or individual with `SoundStreamControl.resume()`.
  Future<void> pauseAllFx() {
    return Future.forEach<SoundStreamControl>(
        _trackedFxStreams, (stream) => stream.pause());
  }

  /// Pauses all tracked music streams. They may be resumed with `resumeAll()`, or individual with `SoundStreamControl.resume()`.
  Future<void> pauseAllMusic() {
    return Future.forEach<SoundStreamControl>(
        _trackedMusicStreams, (stream) => stream.pause());
  }

  /// Resumes all tracked fx streams that had been previously paused.
  Future<void> resumeAllFx() {
    return Future.forEach<SoundStreamControl>(
        _trackedFxStreams, (stream) => stream.resume());
  }

  /// Resumes all tracked music streams that had been previously paused.
  Future<void> resumeAllMusic() {
    return Future.forEach<SoundStreamControl>(
        _trackedMusicStreams, (stream) => stream.resume());
  }

  Future<void> _stopAllFxAndClear() async {
    await stopAllFx();
    _fxNameToDefMap.clear();
  }

  Future<void> _stopAllMusicAndClear() async {
    await stopAllMusic();
    _musicNameToFileMap.clear();
  }

  /// Unloads all previously loaded fx. You won't be able to play more fx unless you load it first.
  Future<void> unloadAllFx() async {
    final trackedStreamsBefore =
        List<SoundStreamControl>.from(_trackedFxStreams);
    await _stopAllFxAndClear();
    await Future.forEach<SoundStreamControl>(
        trackedStreamsBefore, (stream) => stream.release());
    // TODO return _soundpool.release();
  }

  /// Unloads all previously loaded music. You won't be able to play more music unless you load it first.
  Future<void> unloadAllMusic() async {
    final trackedStreamsBefore =
        List<SoundStreamControl>.from(_trackedMusicStreams);
    await _stopAllMusicAndClear();
    await Future.forEach<SoundStreamControl>(
        trackedStreamsBefore, (stream) => stream.release());
    // TODO This doesn't actually remove the temp files. Maybe we should do that first.
    // TODO return _audioCache.clearCache();
  }
}

abstract class SoundStreamControl {
  bool _playing = true;
  bool _stopped = false;

  /// Returns true if stream has not been explicitly paused or stopped. This does not reflect actual player state.
  bool get playing => _playing;

  /// Returns true if stream has been stopped and cannot be resumed. This does not reflect actual player state.
  bool get stopped => _stopped;

  /// Stops playing the stream associated with this object
  Future<void> stop() async {
    await _rawStop();
    _stopped = true;
    _playing = false;
  }

  Future<void> _rawStop();

  /// Pauses playing the stream associated with this object
  Future<void> pause() async {
    if (!_stopped && _playing) {
      await _rawPause();
      _playing = false;
    }
  }

  Future<void> _rawPause();

  /// Resumes the paused stream.
  Future<void> resume() async {
    if (!_stopped && !_playing) {
      await _rawResume();
      _playing = true;
    }
  }

  Future<void> _rawResume();

  /// Sets volume for the sound.
  Future<void> setVolume(double volume);

  Future<void> release() => Future.value();
}

class _SoundPoolSoundStreamControl extends SoundStreamControl {
  // final Soundpool _pool;

  /// Soundpool stream id
  final int _streamId = 0; // TODO

  _SoundPoolSoundStreamControl._(); // TODO this._pool, this._streamId);

  @override
  Future<void> _rawStop() => Future.value(); //=> _pool.stop(_streamId);

  @override
  Future<void> _rawPause() => Future.value(); //=> _pool.pause(_streamId);

  @override
  Future<void> _rawResume() => Future.value(); //=> _pool.resume(_streamId);

  @override
  Future<void> setVolume(double volume) => Future
      .value(); //=>      _pool.setVolume(streamId: _streamId, volume: volume);
}

class _AudioPlaySoundStreamControl extends SoundStreamControl {
  // TODO final AudioPlayer _audioPlayer;

  _AudioPlaySoundStreamControl._(String? nullish); // TODO this._audioPlayer);

  @override
  Future<void> _rawStop() => Future.value(); // TODO => _audioPlayer.stop();

  @override
  Future<void> _rawPause() => Future.value(); // TODO => _audioPlayer.pause();

  @override
  Future<void> _rawResume() => Future.value(); // TODO => _audioPlayer.resume();

  @override
  Future<void> setVolume(double volume) =>
      Future.value(); // TODO => _audioPlayer.setVolume(volume);

  @override
  Future<void> release() => Future.value(); // TODO => _audioPlayer.release();
}

class _SoundDef {
  int soundId;
  String assetName;

  _SoundDef(this.soundId, this.assetName);
}
