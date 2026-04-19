import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../data/models.dart';

class HealthDataProvider extends ChangeNotifier {
  final ApiClient Function() _clientFactory;
  bool _busy = false;

  HealthDataProvider(this._clientFactory);

  bool get isBusy => _busy;

  Future<bool> logWeight(double weight) async {
    _busy = true;
    notifyListeners();
    final entry = WeightEntry(weight: weight, date: DateTime.now());
    final success = await _clientFactory().logWeight(entry);
    _busy = false;
    notifyListeners();
    return success;
  }

  Future<bool> logBP(int systolic, int diastolic) async {
    _busy = true;
    notifyListeners();
    final entry = BPEntry(
      systolic: systolic,
      diastolic: diastolic,
      date: DateTime.now(),
    );
    final success = await _clientFactory().logBP(entry);
    _busy = false;
    notifyListeners();
    return success;
  }

  Future<bool> logBoth(double weight, int systolic, int diastolic) async {
    _busy = true;
    notifyListeners();
    final w = WeightEntry(weight: weight, date: DateTime.now());
    final bp = BPEntry(
      systolic: systolic,
      diastolic: diastolic,
      date: DateTime.now(),
    );
    final success = await _clientFactory().logBoth(w, bp);
    _busy = false;
    notifyListeners();
    return success;
  }
}
