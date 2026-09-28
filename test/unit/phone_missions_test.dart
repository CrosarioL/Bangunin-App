import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakio/features/missions/data/shake_counter.dart';
import 'package:wakio/features/missions/domain/math_problem.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/ringing/domain/emergency_escape.dart';

void main() {
  group('MathProblem', () {
    test('stays in a half-asleep range and fits the answer box', () {
      final random = math.Random(7);
      for (var i = 0; i < 500; i++) {
        final p = MathProblem.random(random);
        expect(p.a, inInclusiveRange(3, 9));
        expect(p.b, inInclusiveRange(3, 9));
        expect(p.c, inInclusiveRange(10, 49));
        expect('${p.answer}'.length, lessThanOrEqualTo(MathProblem.maxDigits));
      }
    });

    test('prompt and answer agree', () {
      const p = MathProblem(7, 8, 13);
      expect(p.prompt, '7 × 8 + 13');
      expect(p.answer, 69);
    });
  });

  group('ShakeCounter', () {
    late StreamController<UserAccelerometerEvent> events;
    late DateTime now;
    late ShakeCounter counter;

    UserAccelerometerEvent accel(double x) =>
        UserAccelerometerEvent(x, 0, 0, DateTime(2026));

    setUp(() {
      events = StreamController<UserAccelerometerEvent>();
      now = DateTime(2026);
      counter = ShakeCounter(target: 3, events: events.stream, clock: () => now)
        ..start();
    });

    tearDown(() async {
      await counter.dispose();
      await events.close();
    });

    Future<void> send(double x, {int afterMs = 200}) async {
      now = now.add(Duration(milliseconds: afterMs));
      events.add(accel(x));
      await Future<void>.delayed(Duration.zero);
    }

    test('one spike counts once until the phone settles again', () async {
      await send(20);
      await send(22); // Still mid-jolt: not re-armed.
      expect(counter.count, 1);
      await send(1); // Settles, re-arms.
      await send(18);
      expect(counter.count, 2);
    });

    test('gentle movement never counts', () async {
      for (var i = 0; i < 20; i++) {
        await send(i.isEven ? 9 : 1);
      }
      expect(counter.count, 0);
    });

    test('stops at the target', () async {
      for (var i = 0; i < 6; i++) {
        await send(20);
        await send(0);
      }
      expect(counter.count, 3);
      expect(counter.isComplete, isTrue);
    });
  });

  group('MissionType counts', () {
    test('every counted mission has options including its default', () {
      for (final mission in MissionType.values) {
        expect(mission.hasCount, mission.defaultReps > 0, reason: mission.name);
        if (mission.hasCount) {
          expect(mission.countOptions, contains(mission.defaultReps));
        }
      }
    });
  });

  group('EmergencyEscape', () {
    test('the pledge grows with each escape this month, then caps', () {
      final first = EmergencyEscape.pledge('en', usedThisMonth: 0);
      final second = EmergencyEscape.pledge('en', usedThisMonth: 1);
      final capped = EmergencyEscape.pledge('en', usedThisMonth: 99);
      expect(second.length, greaterThan(first.length));
      expect(second, startsWith(first));
      expect(capped, EmergencyEscape.pledge('en', usedThisMonth: 3));
    });

    test('is localised', () {
      expect(
        EmergencyEscape.pledge('id', usedThisMonth: 0),
        contains('darurat'),
      );
    });

    test('matching ignores case, spacing and punctuation but not words', () {
      const pledge = 'I know this does not count.';
      expect(
        EmergencyEscape.matches('i KNOW this  does not count', pledge),
        isTrue,
      );
      expect(
        EmergencyEscape.matches('I know this does count.', pledge),
        isFalse,
      );
      expect(EmergencyEscape.matches('', pledge), isFalse);
    });

    test('month key resets each calendar month', () {
      expect(EmergencyEscape.monthKey(DateTime(2026, 9, 30)), '2026-09');
      expect(EmergencyEscape.monthKey(DateTime(2026, 10, 1)), '2026-10');
    });
  });
}
