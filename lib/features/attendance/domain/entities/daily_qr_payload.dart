import 'dart:convert';
import 'package:crypto/crypto.dart';

class DailyQRPayload {
  const DailyQRPayload({
    required this.gymId,
    required this.gymName,
    required this.date,
    required this.token,
    this.type = 'sweatsync_attendance',
  });

  final String gymId;
  final String gymName;
  final String date; // 'YYYY-MM-DD'
  final String token;
  final String type;

  /// Generates the daily deterministic SHA-256 token for a given gym on a specific date.
  /// This token changes every single day at 00:00.
  static String generateDailyToken(String gymId, String date) {
    const salt = 'SweatSync_Daily_Salt_2026_SecureKey';
    final bytes = utf8.encode('$gymId:$date:$salt');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Helper to get today's date formatted as YYYY-MM-DD
  static String getTodayKey([DateTime? now]) {
    final date = now ?? DateTime.now();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create a payload for today's date
  factory DailyQRPayload.createForToday({
    required String gymId,
    required String gymName,
  }) {
    final today = getTodayKey();
    final token = generateDailyToken(gymId, today);
    return DailyQRPayload(
      gymId: gymId,
      gymName: gymName,
      date: today,
      token: token,
    );
  }

  /// Serializes payload to JSON string encoded in the QR code
  String encode() {
    return jsonEncode({
      'type': type,
      'gymId': gymId,
      'gymName': gymName,
      'date': date,
      'token': token,
    });
  }

  /// Parse and validate a raw string scanned from a QR code
  static DailyQRPayload? tryDecode(String rawData) {
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded['type'] != 'sweatsync_attendance') {
        return null;
      }

      final gymId = decoded['gymId'] as String?;
      final gymName = decoded['gymName'] as String? ?? 'Gym';
      final date = decoded['date'] as String?;
      final token = decoded['token'] as String?;

      if (gymId == null || gymId.isEmpty || date == null || date.isEmpty || token == null || token.isEmpty) {
        return null;
      }

      return DailyQRPayload(
        gymId: gymId,
        gymName: gymName,
        date: date,
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  /// Verifies whether the scanned QR payload is valid for today and matches expected gym token
  bool isValidForToday({String? targetGymId}) {
    final today = getTodayKey();
    if (date != today) {
      return false;
    }

    if (targetGymId != null && targetGymId.isNotEmpty && gymId != targetGymId) {
      return false;
    }

    final expectedToken = generateDailyToken(gymId, today);
    return token == expectedToken;
  }
}
