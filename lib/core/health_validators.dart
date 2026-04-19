/// Pure validation and calculation functions for health data.
///
/// Extracted from providers so they can be unit-tested without
/// database dependencies.
class HealthValidators {
  // --- Validation ---

  /// Validates weight is within a physiologically plausible range.
  /// Throws [ArgumentError] if invalid.
  static void validateWeight(double weight) {
    if (weight <= 0 || weight > 500) {
      throw ArgumentError('Weight must be between 0.1 and 500 kg');
    }
  }

  /// Validates blood pressure readings.
  /// Throws [ArgumentError] if values are out of range or diastolic >= systolic.
  static void validateBP(int systolic, int diastolic) {
    if (systolic < 40 || systolic > 300) {
      throw ArgumentError('Systolic must be between 40 and 300 mmHg');
    }
    if (diastolic < 20 || diastolic > 200) {
      throw ArgumentError('Diastolic must be between 20 and 200 mmHg');
    }
    if (diastolic >= systolic) {
      throw ArgumentError('Diastolic must be less than systolic');
    }
  }

  /// Validates heart rate is within a physiologically plausible range.
  /// Throws [ArgumentError] if invalid.
  static void validateHeartRate(int bpm) {
    if (bpm < 20 || bpm > 300) {
      throw ArgumentError('Heart rate must be between 20 and 300 bpm');
    }
  }

  /// Validates mood is one of the allowed values.
  /// Throws [ArgumentError] if invalid.
  static void validateMood(String mood) {
    const validMoods = ['great', 'good', 'okay', 'bad', 'terrible'];
    if (!validMoods.contains(mood.toLowerCase())) {
      throw ArgumentError('Invalid mood value: $mood');
    }
  }

  // --- Calculations ---

  /// Calculates BMI from weight (kg) and height (cm).
  /// Returns null if inputs are invalid.
  static double? calculateBMI(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Classifies a BMI value into a human-readable category.
  static String classifyBMI(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Classifies blood pressure into a clinical status.
  static String classifyBP(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) return 'High';
    if (systolic >= 120 || diastolic >= 80) return 'Elevated';
    return 'Normal';
  }
}
