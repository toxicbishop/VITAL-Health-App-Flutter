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

  String _genUid() => DateTime.now().microsecondsSinceEpoch.toString();

  void _addLocal(LogEntry e) {
    _logs.add(e);
    notifyListeners();
  }

  /// Syncs any log entry to the cloud
  Future<bool> _syncLog(LogEntry entry) async {
    return await _clientFactory().logGeneric(entry);
  }

  /// Deletes a log entry globally
  Future<void> deleteLog(LogEntry entry) async {
    _busy = true;
    notifyListeners();
    final ok = await _clientFactory().deleteLog(entry.uid);
    if (ok) {
      _logs.remove(entry);
    }
    _busy = false;
    notifyListeners();
  }

  /// Refactored to sync with cloud. Previously local-only.
  Future<void> addLog({
    required String logType,
    required String value,
    required String unit,
    String? notes,
  }) async {
    final entry = LogEntry(
      uid: _genUid(),
      logType: logType,
      value: value,
      unit: unit,
      notes: notes,
      timestamp: DateTime.now(),
    );
    _addLocal(entry);
    // Best effort background sync
    _syncLog(entry);
  }

  Future<bool> logWeight(double weight, {String? notes}) async {
    _busy = true;
    notifyListeners();
    final now = DateTime.now();
    final uid = _genUid();
    final entry = WeightEntry(uid: uid, weight: weight, date: now);
    final success = await _clientFactory().logWeight(entry);
    if (success) {
      _addLocal(LogEntry(
        uid: uid,
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
    final uid = _genUid();
    final entry = BPEntry(uid: uid, systolic: systolic, diastolic: diastolic, date: now);
    final success = await _clientFactory().logBP(entry);
    if (success) {
      _addLocal(LogEntry(
        uid: uid,
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
    final uid = _genUid();
    final entry = HeartRateEntry(uid: uid, bpm: bpm, date: now);
    final success = await _clientFactory().logHr(entry);
    if (success) {
      _addLocal(LogEntry(
        uid: uid,
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
    final uid = _genUid();
    final entry = BothEntry(
      uid: uid,
      weight: weight,
      systolic: systolic,
      diastolic: diastolic,
      date: now,
    );
    final success = await _clientFactory().logBoth(entry);
    if (success) {
      _addLocal(LogEntry(
        uid: uid,
        logType: 'WEIGHT',
        value: weight.toString(),
        unit: 'kg',
        notes: notes,
        timestamp: now,
      ));
      _addLocal(LogEntry(
        uid: uid, // Shared UID for synchronized BOTH entries
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
