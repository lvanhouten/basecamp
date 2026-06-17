import 'package:basecamp/features/clock/data/chime_player.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the audio operations so the looping-playback capability is asserted
/// without actually playing audio (no plugin).
class _FakeSink implements ChimeAudioSink {
  final looped = <String>[];
  int stops = 0;

  @override
  Future<void> loopAsset(String assetPath) async => looped.add(assetPath);

  @override
  Future<void> stop() async => stops++;
}

void main() {
  test('start loops the bundled default chime asset', () async {
    final sink = _FakeSink();
    final player = DefaultChimePlayer(sink: sink);

    await player.start();

    expect(sink.looped, [defaultChimeAsset]);
    expect(defaultChimeAsset, 'assets/audio/chime.wav');
  });

  test('stop halts playback', () async {
    final sink = _FakeSink();
    final player = DefaultChimePlayer(sink: sink);

    await player.start();
    await player.stop();

    expect(sink.stops, 1);
  });

  test('a fresh ring restarts the loop (start is idempotent-by-restart)',
      () async {
    final sink = _FakeSink();
    final player = DefaultChimePlayer(sink: sink);

    await player.start();
    await player.start();

    expect(sink.looped, hasLength(2),
        reason: 'each start re-issues the loop from the beginning');
  });

  test('a custom asset path is honoured (per-alarm chime is a later caller '
      'change)', () async {
    final sink = _FakeSink();
    final player =
        DefaultChimePlayer(sink: sink, assetPath: 'assets/audio/other.wav');

    await player.start();
    expect(sink.looped, ['assets/audio/other.wav']);
  });

  test('NoopChimePlayer does nothing (safe default)', () async {
    const player = NoopChimePlayer();
    await player.start();
    await player.stop();
    // No throw, no state — that is the contract.
  });
}
