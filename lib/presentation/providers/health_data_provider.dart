import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../data/models.dart';

class HealthDataProvider extends ChangeNotifier {
  final ApiClient Function() _clientFactory;
  bool _busy = false;
  final List<LogEntry> _logs = [];

  HealthDataProvider(this._clientFactory);

  bool get isBusy => _busy;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void _add(LogEntry e) {
    _logs.add(e);
    notifyListeners();
  }

  /// Local-only removal — used for items that were never persisted
  /// (mood, medication, appointment, note).
  void removeLog(LogEntry entry) {
    _logs.remove(entry);
    notifyListeners();
  }

  /// Generic local-only log add (used by mood, medication, HR, appointment,
  /// note — not part of the PRD persistence path).
  void addLog({
    required String logType,
    required String value,
    required String unit,
    String? notes,
  }) {
    _add(LogEntry(
      logType: logType,
      value: value,
      unit: unit,
      notes: notes,
      timestamp: DateTime.now(),
    ));
  }

  Future<bool> logWeight(double weight, {String? notes}) async {
    _busy = true;
    notifyListeners();
    final now = DateTime.now();
    final entry = WeightEntry(weight: weight, date: now);
    final success = await _clientFactory().logWeight(entry);
    if (success) {
      _add(LogEntry(
        logType: 'WEIGHT',
        value: weight.toString(),
        unit: 'kg',
        notes: notes,
        timestamp: now,
      ));
    }
    _busy = false;
    notifyListeners();
    return success;
  }

  Future<bool> logBP(int systolic, int diastolic, {String? notes}) async {
    _busy = true;
    notifyListeners();
    final now = DateTime.now();
    final entry = BPEntry(systolic: systolic, diastolic: diastolic, date: now);
    final success = await _clientFactory().logBP(entry);
    if (success) {
      _add(LogEntry(
        logType: 'BLOOD_PRESSURE',
        value: '$systolic/$diastolic',
        unit: 'mmHg',
        notes: notes,
        timestamp: now,
      ));
    }
    _busy = false;
    notifyListeners();
    return success;
  }

  Future<bool> logHr(int bpm, {String? notes}) async {
    _busy = true;
    notifyListeners();
    final now = DateTime.now();
    final entry = HeartRateEntry(bpm: bpm, date: now);
    final success = await _clientFactory().logHr(entry);
    if (success) {
      _add(LogEntry(
        logType: 'HEART_RATE',
        value: bpm.toString(),
        unit: 'bpm',
        notes: notes,
        timestamp: now,
      ));
    }
    _busy = false;
    notifyListeners();
    return success;
  }

  Future<bool> logBoth(
    double weight,
    int systolic,
    int diastolic, {
    String? notes,
  }) async {
    _busy = true;
    notifyListeners();
    final now = DateTime.now();
    final entry = BothEntry(
      weight: weight,
      systolic: systolic,
      diastolic: diastolic,
      date: now,
    );
    final success = await _clientFactory().logBoth(entry);
    if (success) {
      _add(LogEntry(
        logType: 'WEIGHT',
        value: weight.toString(),
        unit: 'kg',
        notes: notes,
        timestamp: now,
      ));
      _add(LogEntry(
        logType: 'BLOOD_PRESSURE',
        value: '$systolic/$diastolic',
        unit: 'mmHg',
        notes: notes,
        timestamp: now,
      ));
    }
    _busy = false;
    notifyListeners();
    return success;
  }
}
