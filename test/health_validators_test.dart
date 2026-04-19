import 'package:flutter_test/flutter_test.dart';
import 'package:vital_flutter_app/core/health_validators.dart';

void main() {
  // ─── Weight Validation ───────────────────────────────────────

  group('Weight validation', () {
    test('accepts valid weight', () {
      expect(() => HealthValidators.validateWeight(70.0), returnsNormally);
    });

    test('accepts boundary low (0.1 kg)', () {
      expect(() => HealthValidators.validateWeight(0.1), returnsNormally);
    });

    test('accepts boundary high (500 kg)', () {
      expect(() => HealthValidators.validateWeight(500), returnsNormally);
    });

    test('rejects zero weight', () {
      expect(
        () => HealthValidators.validateWeight(0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects negative weight', () {
      expect(
        () => HealthValidators.validateWeight(-5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects weight above 500 kg', () {
      expect(
        () => HealthValidators.validateWeight(501),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─── Blood Pressure Validation ───────────────────────────────

  group('Blood pressure validation', () {
    test('accepts normal BP (120/80)', () {
      expect(() => HealthValidators.validateBP(120, 80), returnsNormally);
    });

    test('accepts boundary low (40/20)', () {
      expect(() => HealthValidators.validateBP(41, 20), returnsNormally);
    });

    test('accepts boundary high (300/200)', () {
      expect(() => HealthValidators.validateBP(300, 199), returnsNormally);
    });

    test('rejects systolic below 40', () {
      expect(
        () => HealthValidators.validateBP(39, 30),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects systolic above 300', () {
      expect(
        () => HealthValidators.validateBP(301, 80),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects diastolic below 20', () {
      expect(
        () => HealthValidators.validateBP(120, 19),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects diastolic above 200', () {
      expect(
        () => HealthValidators.validateBP(250, 201),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects diastolic >= systolic', () {
      expect(
        () => HealthValidators.validateBP(80, 80),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects diastolic > systolic', () {
      expect(
        () => HealthValidators.validateBP(80, 120),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─── Heart Rate Validation ───────────────────────────────────

  group('Heart rate validation', () {
    test('accepts normal HR', () {
      expect(() => HealthValidators.validateHeartRate(72), returnsNormally);
    });

    test('accepts boundary low (20 bpm)', () {
      expect(() => HealthValidators.validateHeartRate(20), returnsNormally);
    });

    test('accepts boundary high (300 bpm)', () {
      expect(() => HealthValidators.validateHeartRate(300), returnsNormally);
    });

    test('rejects HR below 20', () {
      expect(
        () => HealthValidators.validateHeartRate(19),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects HR above 300', () {
      expect(
        () => HealthValidators.validateHeartRate(301),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─── Mood Validation ─────────────────────────────────────────

  group('Mood validation', () {
    test('accepts "great"', () {
      expect(() => HealthValidators.validateMood('great'), returnsNormally);
    });

    test('accepts "Good" (case-insensitive)', () {
      expect(() => HealthValidators.validateMood('Good'), returnsNormally);
    });

    test('accepts all valid moods', () {
      for (final mood in ['great', 'good', 'okay', 'bad', 'terrible']) {
        expect(() => HealthValidators.validateMood(mood), returnsNormally);
      }
    });

    test('rejects invalid mood', () {
      expect(
        () => HealthValidators.validateMood('amazing'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects empty string', () {
      expect(
        () => HealthValidators.validateMood(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─── BMI Calculation ─────────────────────────────────────────

  group('BMI calculation', () {
    test('calculates correct BMI for 70 kg / 175 cm', () {
      final bmi = HealthValidators.calculateBMI(70, 175);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(22.86, 0.01));
    });

    test('calculates correct BMI for 100 kg / 180 cm', () {
      final bmi = HealthValidators.calculateBMI(100, 180);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(30.86, 0.01));
    });

    test('returns null for zero weight', () {
      expect(HealthValidators.calculateBMI(0, 175), isNull);
    });

    test('returns null for zero height', () {
      expect(HealthValidators.calculateBMI(70, 0), isNull);
    });

    test('returns null for negative values', () {
      expect(HealthValidators.calculateBMI(-70, 175), isNull);
      expect(HealthValidators.calculateBMI(70, -175), isNull);
    });
  });

  // ─── BMI Classification ──────────────────────────────────────

  group('BMI classification', () {
    test('classifies underweight (BMI < 18.5)', () {
      expect(HealthValidators.classifyBMI(17.0), 'Underweight');
    });

    test('classifies normal (18.5 <= BMI < 25)', () {
      expect(HealthValidators.classifyBMI(22.0), 'Normal');
    });

    test('classifies overweight (25 <= BMI < 30)', () {
      expect(HealthValidators.classifyBMI(27.0), 'Overweight');
    });

    test('classifies obese (BMI >= 30)', () {
      expect(HealthValidators.classifyBMI(35.0), 'Obese');
    });

    test('boundary: 18.5 is Normal', () {
      expect(HealthValidators.classifyBMI(18.5), 'Normal');
    });

    test('boundary: 25.0 is Overweight', () {
      expect(HealthValidators.classifyBMI(25.0), 'Overweight');
    });

    test('boundary: 30.0 is Obese', () {
      expect(HealthValidators.classifyBMI(30.0), 'Obese');
    });
  });

  // ─── BP Classification ───────────────────────────────────────

  group('BP classification', () {
    test('classifies normal BP (110/70)', () {
      expect(HealthValidators.classifyBP(110, 70), 'Normal');
    });

    test('classifies elevated BP (125/75)', () {
      expect(HealthValidators.classifyBP(125, 75), 'Elevated');
    });

    test('classifies high BP (145/95)', () {
      expect(HealthValidators.classifyBP(145, 95), 'High');
    });

    test('high systolic alone triggers High', () {
      expect(HealthValidators.classifyBP(140, 70), 'High');
    });

    test('high diastolic alone triggers High', () {
      expect(HealthValidators.classifyBP(110, 90), 'High');
    });

    test('boundary: 120/79 is Elevated', () {
      expect(HealthValidators.classifyBP(120, 79), 'Elevated');
    });

    test('boundary: 119/79 is Normal', () {
      expect(HealthValidators.classifyBP(119, 79), 'Normal');
    });
  });
}
