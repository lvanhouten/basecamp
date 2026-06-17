import 'dart:async';

import 'package:basecamp/core/providers.dart';
import 'package:basecamp/features/clock/alarm_launch_host.dart';
import 'package:basecamp/features/clock/alarm_ringing_screen.dart';
import 'package:basecamp/features/clock/data/alarm_launch_router.dart';
import 'package:basecamp/features/clock/data/chime_player.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A controllable [AlarmLaunchRouter]: a fixed cold-launch id and a manual warm
/// stream, so the root's routing-to-ring-screen is verified without the plugin.
class _FakeLaunchRouter implements AlarmLaunchRouter {
  _FakeLaunchRouter({this.coldId});

  final int? coldId;
  final _warm = StreamController<int>.broadcast();

  void fireWarm(int id) => _warm.add(id);

  @override
  Future<int?> coldLaunchAlarmId() async => coldId;

  @override
  Stream<int> get warmAlarmIds => _warm.stream;

  Future<void> close() => _warm.close();
}

void main() {
  group('parseAlarmPayload (pure)', () {
    test('decodes the alarm:<id> convention from ClockRepository.alarmPayload',
        () {
      expect(parseAlarmPayload(ClockRepository.alarmPayload(42)), 42);
      expect(parseAlarmPayload('alarm:7'), 7);
    });

    test('rejects null, non-alarm, and malformed payloads', () {
      expect(parseAlarmPayload(null), isNull);
      expect(parseAlarmPayload('timer:5'), isNull); // timer routing, not ours
      expect(parseAlarmPayload('alarm:'), isNull);
      expect(parseAlarmPayload('alarm:abc'), isNull);
      expect(parseAlarmPayload('42'), isNull);
    });
  });

  group('AlarmLaunchHost routing', () {
    // The ring screen the host pushes starts the chime on mount — keep audio out
    // of the test. The host needs only the launch router; a trivial child stands
    // in for the hub (the routing under test is independent of it).
    Future<void> pumpHost(
      WidgetTester tester,
      _FakeLaunchRouter router,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alarmLaunchRouterProvider.overrideWithValue(router),
            chimePlayerProvider.overrideWithValue(const NoopChimePlayer()),
            // The pushed ring screen watches alarmsProvider on build; stub it
            // empty so the real on-disk Drift DB is never opened (the screen
            // falls back to a generic ring, which is all this routing test needs).
            alarmsProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: AlarmLaunchHost(
              child: Scaffold(body: Center(child: Text('hub'))),
            ),
          ),
        ),
      );
      // Build + the post-frame wiring + the async cold-launch read + the ring
      // route transition. pumpAndSettle is safe here: the trivial child has no
      // perpetual animation (unlike the real hub).
      await tester.pumpAndSettle();
    }

    testWidgets('a cold-launch alarm id pushes the ring screen for that alarm',
        (tester) async {
      final router = _FakeLaunchRouter(coldId: 5);
      addTearDown(router.close);

      await pumpHost(tester, router);

      final ring = tester.widget<AlarmRingingScreen>(
        find.byType(AlarmRingingScreen),
      );
      expect(ring.alarmId, 5);
      // The hub is now behind the ring screen.
      expect(find.text('hub'), findsNothing);
    });

    testWidgets('no cold-launch alarm shows the hub, not a ring screen',
        (tester) async {
      final router = _FakeLaunchRouter(coldId: null);
      addTearDown(router.close);

      await pumpHost(tester, router);

      expect(find.byType(AlarmRingingScreen), findsNothing);
      expect(find.text('hub'), findsOneWidget);
    });

    testWidgets('a warm notification pushes the ring screen for that alarm',
        (tester) async {
      final router = _FakeLaunchRouter(coldId: null);
      addTearDown(router.close);

      await pumpHost(tester, router);
      expect(find.byType(AlarmRingingScreen), findsNothing);

      // An alarm fires while the app is alive.
      router.fireWarm(13);
      await tester.pumpAndSettle();

      final ring = tester.widget<AlarmRingingScreen>(
        find.byType(AlarmRingingScreen),
      );
      expect(ring.alarmId, 13);
    });
  });
}
