import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// The looping-audio capability the alarm ring screen (08-alarm-ui) drives:
/// [start] begins looping the bundled default chime, [stop] silences it. The
/// ring screen calls [start] when the full-screen intent opens it and [stop] on
/// Snooze / Dismiss (ADR-0003: continuous ringing is the launched screen's job,
/// not the one-shot notification sound).
///
/// The audio backend is abstracted behind [ChimeAudioSink] so the capability is
/// testable without actually playing audio — tests inject a fake sink and
/// assert start/stop/loop coordination.
abstract interface class ChimePlayer {
  /// Begin looping the chime from the start. Idempotent: calling [start] while
  /// already playing restarts from the beginning (a fresh ring).
  Future<void> start();

  /// Stop playback. No-op if not playing.
  Future<void> stop();
}

/// The minimal audio operations [DefaultChimePlayer] needs, abstracted so tests
/// can inject a recording fake. Maps 1:1 onto the slice of `audioplayers` we
/// use, keeping the package dependency out of test code.
abstract interface class ChimeAudioSink {
  /// Loop the asset at [assetPath] forever until [stop].
  Future<void> loopAsset(String assetPath);

  /// Stop and release playback.
  Future<void> stop();
}

/// The bundled default chime asset.
///
/// ⚠️ ORCHESTRATOR: `assets/audio/chime.wav` committed by this brief is a TEXT
/// PLACEHOLDER, not real audio — a binary `.wav` can't be authored with text
/// tools. REPLACE it with a real looping chime before shipping, or the ring is
/// silent. The path/declaration (pubspec `flutter/assets`) is correct; only the
/// bytes need swapping.
const String defaultChimeAsset = 'assets/audio/chime.wav';

/// Real [ChimePlayer] over [ChimeAudioSink] (which wraps `audioplayers`).
class DefaultChimePlayer implements ChimePlayer {
  DefaultChimePlayer({
    ChimeAudioSink? sink,
    this.assetPath = defaultChimeAsset,
  }) : _sink = sink ?? AudioPlayersChimeSink();

  final ChimeAudioSink _sink;

  /// The asset looped by [start]; defaults to [defaultChimeAsset].
  final String assetPath;

  @override
  Future<void> start() => _sink.loopAsset(assetPath);

  @override
  Future<void> stop() => _sink.stop();
}

/// `audioplayers`-backed [ChimeAudioSink]. Sets release-mode loop and plays the
/// asset; [stop] halts and releases. The `AssetSource` path is relative to the
/// `assets/` prefix `audioplayers` strips, so we pass the path WITHOUT the
/// leading `assets/`.
class AudioPlayersChimeSink implements ChimeAudioSink {
  AudioPlayersChimeSink([AudioPlayer? player])
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> loopAsset(String assetPath) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    // audioplayers' AssetSource is rooted at `assets/`, so strip that prefix.
    final source = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
    await _player.stop();
    await _player.play(AssetSource(source));
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.release();
  }
}

/// A [ChimePlayer] that does nothing — the safe default in non-mobile/test
/// contexts where the audio plugin isn't wired. Tests inject their own recording
/// fake to assert start/stop instead.
@visibleForTesting
class NoopChimePlayer implements ChimePlayer {
  const NoopChimePlayer();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
