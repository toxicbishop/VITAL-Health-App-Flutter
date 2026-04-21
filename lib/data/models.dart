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
      };
}
