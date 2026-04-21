import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({String? title, String? body, DateTime? updatedAt}) =>
      JournalEntry(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );
}

class JournalProvider extends ChangeNotifier {
  static const _prefsKey = 'journal_entries';
  final List<JournalEntry> _entries = [];

  List<JournalEntry> get entries {
    final sorted = [..._entries]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(sorted);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _entries.clear();
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries.addAll(decoded.map(
          (e) => JournalEntry.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  Future<JournalEntry> add({required String title, required String body}) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: now,
      updatedAt: now,
    );
    _entries.add(entry);
    notifyListeners();
    await _persist();
    return entry;
  }

  Future<void> update(String id,
      {required String title, required String body}) async {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _entries[idx] = _entries[idx].copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }
}
