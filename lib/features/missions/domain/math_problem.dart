import 'dart:math' as math;

/// One Math-mission sum: either `a + b` or a small times table, `a × b`.
///
/// Sized for someone who has been awake for four seconds. It should take a
/// moment's thought (27 + 8, 6 × 4), never a working-out. The old
/// `a × b + c` form ("9 × 7 + 59") was too much at that hour.
class MathProblem {
  const MathProblem.add(this.a, this.b) : multiply = false;
  const MathProblem.times(this.a, this.b) : multiply = true;

  factory MathProblem.random(math.Random random) => random.nextBool()
      ? MathProblem.add(
          12 + random.nextInt(38), // 12..49
          3 + random.nextInt(7), // 3..9
        )
      : MathProblem.times(
          2 + random.nextInt(8), // 2..9
          2 + random.nextInt(4), // 2..5
        );

  final int a;
  final int b;
  final bool multiply;

  int get answer => multiply ? a * b : a + b;

  String get prompt => multiply ? '$a × $b' : '$a + $b';

  /// Answers never exceed 2 digits (max 49 + 9 = 58, 9 × 5 = 45).
  static const maxDigits = 2;
}
