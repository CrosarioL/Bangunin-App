import 'dart:math' as math;

/// One Math-mission sum, always `a × b + c`.
///
/// Sized for someone who has been awake for four seconds: the product needs
/// real attention (7 × 8, not 2 × 3), but nothing needs pen and paper. A
/// sum you can't do half asleep is a mission people uninstall over.
class MathProblem {
  const MathProblem(this.a, this.b, this.c);

  factory MathProblem.random(math.Random random) => MathProblem(
    3 + random.nextInt(7), // 3..9
    3 + random.nextInt(7), // 3..9
    10 + random.nextInt(40), // 10..49
  );

  final int a;
  final int b;
  final int c;

  int get answer => a * b + c;

  String get prompt => '$a × $b + $c';

  /// Answers never exceed 3 digits (max 9 × 9 + 49 = 130).
  static const maxDigits = 3;
}
