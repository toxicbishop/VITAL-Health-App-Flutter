/// Lightweight in-app log record.
class LogEntry {
  final String uid; // Added for Full CRUD support
  final String logType;
  final String value;
  final String unit;
  final String? notes;
  final DateTime timestamp;

  LogEntry({
    required this.uid,
    required this.logType,
    required this.value,
    required this.unit,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'type': logType,
        'value': value,
        'unit': unit,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };
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
  final String uid;
  final double weight;
  final DateTime date;

  WeightEntry({required this.uid, required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'timestamp': date.toIso8601String(),
        'type': 'WEIGHT',
        'weight': weight,
        'value': weight.toString(),
        'unit': 'kg',
        'bp_sys': null,
        'bp_dia': null,
        'hr': null,
      };
}

class BPEntry {
  final String uid;
  final int systolic;
  final int diastolic;
  final DateTime date;

  BPEntry({
    required this.uid,
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'timestamp': date.toIso8601String(),
        'type': 'BP',
        'value': '$systolic/$diastolic',
        'unit': 'mmHg',
        'weight': null,
        'bp_sys': systolic,
        'bp_dia': diastolic,
        'hr': null,
      };
}

class BothEntry {
  final String uid;
  final double weight;
  final int systolic;
  final int diastolic;
  final DateTime date;

  BothEntry({
    required this.uid,
    required this.weight,
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'timestamp': date.toIso8601String(),
        'type': 'BOTH',
        'weight': weight,
        'bp_sys': systolic,
        'bp_dia': diastolic,
        'value': '$weight kg, $systolic/$diastolic mmHg',
        'unit': 'combined',
        'hr': null,
      };
}

class HeartRateEntry {
  final String uid;
  final int bpm;
  final DateTime date;

  HeartRateEntry({required this.uid, required this.bpm, required this.date});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'timestamp': date.toIso8601String(),
        'type': 'HEART_RATE',
        'value': bpm.toString(),
        'unit': 'bpm',
        'weight': null,
        'bp_sys': null,
        'bp_dia': null,
        'hr': bpm,
      };
}
