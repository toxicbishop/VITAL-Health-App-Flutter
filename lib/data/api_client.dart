import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiClient {
  final String scriptUrl;

  ApiClient({required this.scriptUrl});

  Future<bool> logWeight(WeightEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode(entry.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logBP(BPEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode(entry.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logBoth(WeightEntry w, BPEntry bp) async {
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({
          'type': 'both',
          'weight': w.weight,
          'systolic': bp.systolic,
          'diastolic': bp.diastolic,
          'date': w.date.toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }
}
