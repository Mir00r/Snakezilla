import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Simple analytics service tracking session data, engagement metrics,
/// and player behavior patterns for retention optimization.
class AnalyticsService {
  static const _kSessionCount = 'analytics_session_count';
  static const _kTotalPlayTime = 'analytics_total_play_time';
  static const _kLastSessionDate = 'analytics_last_session';
  static const _kModePlayCounts = 'analytics_mode_plays';
  static const _kFeatureClicks = 'analytics_feature_clicks';
  static const _kRetentionDays = 'analytics_retention_days';
  static const _kFirstPlayDate = 'analytics_first_play';

  final SharedPreferences _prefs;

  AnalyticsService(this._prefs);

  // ── Session Tracking ───────────────────────────────────────────────────────

  int get sessionCount => _prefs.getInt(_kSessionCount) ?? 0;
  int get totalPlayTimeSeconds => _prefs.getInt(_kTotalPlayTime) ?? 0;

  void trackSessionStart() {
    _prefs.setInt(_kSessionCount, sessionCount + 1);
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    _prefs.setInt(_kLastSessionDate, today);

    // Set first play date if not set
    if (_prefs.getInt(_kFirstPlayDate) == null) {
      _prefs.setInt(_kFirstPlayDate, today);
    }

    // Track retention days
    _trackRetentionDay(today);
  }

  void trackPlayTime(int seconds) {
    _prefs.setInt(_kTotalPlayTime, totalPlayTimeSeconds + seconds);
  }

  // ── Game Mode Analytics ────────────────────────────────────────────────────

  Map<String, int> get modePlayCounts {
    final raw = _prefs.getString(_kModePlayCounts);
    if (raw == null) return {};
    return Map<String, int>.from(jsonDecode(raw) as Map);
  }

  void trackModePlay(String modeName) {
    final counts = modePlayCounts;
    counts[modeName] = (counts[modeName] ?? 0) + 1;
    _prefs.setString(_kModePlayCounts, jsonEncode(counts));
  }

  String? get mostPlayedMode {
    final counts = modePlayCounts;
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // ── Feature Engagement ─────────────────────────────────────────────────────

  Map<String, int> get featureClicks {
    final raw = _prefs.getString(_kFeatureClicks);
    if (raw == null) return {};
    return Map<String, int>.from(jsonDecode(raw) as Map);
  }

  void trackFeatureClick(String featureName) {
    final clicks = featureClicks;
    clicks[featureName] = (clicks[featureName] ?? 0) + 1;
    _prefs.setString(_kFeatureClicks, jsonEncode(clicks));
  }

  // ── Retention Metrics ──────────────────────────────────────────────────────

  Set<int> get retentionDays {
    final raw = _prefs.getString(_kRetentionDays);
    if (raw == null) return {};
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => e as int)
        .toSet();
  }

  void _trackRetentionDay(int daysSinceEpoch) {
    final days = retentionDays;
    days.add(daysSinceEpoch);
    // Keep only last 90 days
    final cutoff = daysSinceEpoch - 90;
    days.removeWhere((d) => d < cutoff);
    _prefs.setString(_kRetentionDays, jsonEncode(days.toList()));
  }

  int get uniqueActiveDays => retentionDays.length;

  double get day7Retention {
    final first = _prefs.getInt(_kFirstPlayDate);
    if (first == null) return 0.0;
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    if (today - first < 7) return 1.0; // Not enough data
    final days = retentionDays;
    final d7Days = days.where((d) => d >= first && d < first + 7).length;
    return d7Days / 7;
  }

  // ── Summary Report ─────────────────────────────────────────────────────────

  Map<String, dynamic> getSummaryReport() {
    final playHours = totalPlayTimeSeconds / 3600;
    return {
      'totalSessions': sessionCount,
      'totalPlayHours': playHours.toStringAsFixed(1),
      'uniqueDays': uniqueActiveDays,
      'mostPlayedMode': mostPlayedMode ?? 'None',
      'modeBreakdown': modePlayCounts,
      'featureEngagement': featureClicks,
      'day7Retention': '${(day7Retention * 100).toStringAsFixed(0)}%',
    };
  }
}
