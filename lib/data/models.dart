/// Lightweight in-app log record. Mirrors the Kotlin reference
/// `HealthLogEntity`. Weight/BP/Both are also persisted server-side
/// via [ApiClient]; other log types (MOOD, MEDICATION, HEART_RATE,
/// APPOINTMENT, NOTE) are currently local-only — out of PRD scope.
class LogEntry {
  final String logType;
  final String value;
  final String unit;
  final String? notes;
  final DateTime timestamp;

  LogEntry({
    required this.logType,
    required this.value,
    required this.unit,
    this.notes,
    required this.timestamp,
  });
}

class ProfileEntry {
  final String name;
  final DateTime date;

  ProfileEntry({required this.name, required this.date});

  Map<String, dynamic> toJson() => {
        'timestamp': date.toIso8601String(),
        'type': 'PROFILE',
        'name': name,
      };
}

class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
        'timestamp': date.toIso8601String(),
        'type': 'WEIGHT',
        'weight': weight,
        'bp_sys': null,
        'bp_dia': null,
        'hr': null,
      };
}

class BPEntry {
  final int systolic;
  final int diastolic;
  final DateTime date;

  BPEntry({
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': date.toIso8601String(),
        'type': 'BP',
        'weight': null,
        'bp_sys': systolic,
        'bp_dia': diastolic,
        'hr': null,
      };
}

class BothEntry {
  final double weight;
  final int systolic;
  final int diastolic;
  final DateTime date;

  BothEntry({
    required this.weight,
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': date.toIso8601String(),
        'type': 'BOTH',
        'weight': weight,
        'bp_sys': systolic,
        'bp_dia': diastolic,
        'hr': null,
      };
}

class HeartRateEntry {
  final int bpm;
  final DateTime date;

  HeartRateEntry({required this.bpm, required this.date});

  Map<String, dynamic> toJson() => {
        'timestamp': date.toIso8601String(),
        'type': 'HEART_RATE',
        'weight': null,
        'bp_sys': null,
        'bp_dia': null,
        'hr': bpm,
      };
}
