import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/mission.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiService {
  // TODO: Replace with your actual API base URL
  static const String baseUrl = 'https://api.realityanchor.com';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // TODO: Add authentication headers when implementing real backend
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer $token', // Add when auth is implemented
  };

  // TODO: Implement actual API endpoint for fetching missions
  Future<Mission> getNextMission(String childId, int difficultyLevel) async {
    try {
      final uri = Uri.parse('$baseUrl/api/mission/next')
          .replace(queryParameters: {
        'childId': childId,
        'difficulty': difficultyLevel.toString(),
      });

      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Mission.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('No missions available');
      } else {
        throw ApiException('Failed to load mission: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // TODO: Implement actual API endpoint for submitting mission results
  Future<void> submitMissionResult({
    required String missionId,
    required String childId,
    required bool userAnswer,
    required bool isCorrect,
    required Duration timeSpent,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/mission/result');
      final body = jsonEncode({
        'missionId': missionId,
        'childId': childId,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'timeSpentMs': timeSpent.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body,
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw ApiException('Failed to submit result: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit result: $e');
    }
  }

  // TODO: Remove this mock method when real API is implemented
  Mission createMockMission(int index) {
    final missions = [
      Mission(
        id: 'mock_$index',
        type: 'image_verification',
        imageUrl: 'https://picsum.photos/400/300?random=$index',
        questionText: 'Is this a real photo or created by AI? 🤔',
        correctAnswer: index % 2 == 0,
        explanation: index % 2 == 0
            ? '✅ This is a real photo! You can tell because...'
            : '❌ This was created by AI! The clues were...',
        difficultyLevel: (index % 3) + 1,
      ),
    ];
    return missions[0];
  }
  
  // TODO: Add authentication endpoints
  // Future<String> authenticate(String email, String password) async { ... }
  // Future<void> refreshToken() async { ... }
  // Future<List<ChildProfile>> getChildren(String userId) async { ... }
  // Future<UserProgress> getProgress(String childId) async { ... }
}