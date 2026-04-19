class Profile {
  final String name;
  final int age;

  Profile({required this.name, required this.age});

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] as String,
        age: j['age'] as int,
      );

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
        'type': 'weight',
        'weight': weight,
        'date': date.toIso8601String(),
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
        'type': 'bp',
        'systolic': systolic,
        'diastolic': diastolic,
        'date': date.toIso8601String(),
      };
}
