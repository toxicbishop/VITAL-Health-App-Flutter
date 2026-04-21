import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiClient {
  final String scriptUrl;

  ApiClient({required this.scriptUrl});

  Future<bool> _post(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse(scriptUrl),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      // Google Apps Script redirect logic handling
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveProfile(ProfileEntry entry) => _post(entry.toJson());

  Future<bool> logWeight(WeightEntry entry) => _post(entry.toJson());

  Future<bool> logBP(BPEntry entry) => _post(entry.toJson());

  Future<bool> logBoth(BothEntry entry) => _post(entry.toJson());

  Future<bool> logHr(HeartRateEntry entry) => _post(entry.toJson());

  /// Generic log for Medications, Journal entries, etc.
  Future<bool> logGeneric(LogEntry log) => _post(log.toJson());

  /// Deletes a log entry by its unique ID
  Future<bool> deleteLog(String uid) => _post({
        'type': 'DELETE',
        'uid': uid,
      });
}
