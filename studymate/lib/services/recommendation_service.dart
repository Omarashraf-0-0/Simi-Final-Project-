import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation_models.dart';

/// Service for AI-powered recommendation system
class RecommendationService {
  static const String baseUrl = 'https://alyibrahim.pythonanywhere.com';

  /// Get AI recommendations based on quiz results
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [courseId]: Course ID
  /// - [pdfLinks]: List of [path, lecture_number] pairs from course materials
  /// - [quizResults]: Quiz performance data with topics
  Future<RecommendationResponse?> getRecommendations({
    required int userId,
    required int courseId,
    required List<List<dynamic>> pdfLinks,
    required List<QuizResult> quizResults,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/Recommendation');

      final request = RecommendationRequest(
        links: pdfLinks,
        quizResults: quizResults,
      );

      print('🤖 Fetching AI recommendations...');
      print(
          '📚 Course: $courseId, Links: ${pdfLinks.length}, Results: ${quizResults.length}');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout - recommendation generation takes time');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            '✅ Received ${data['recommendations']?.length ?? 0} recommendations');
        return RecommendationResponse.fromJson(data);
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in getRecommendations: $e');
      return null;
    }
  }

  /// Get weak topics for a student (topics with low accuracy)
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [courseId]: Course ID
  /// - [threshold]: Accuracy threshold (default 50%)
  Future<List<WeakTopic>> getWeakTopics({
    required int userId,
    required int courseId,
    double threshold = 50.0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get_weak_topics');

      print('📊 Fetching weak topics for user $userId, course $courseId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserID': userId,
          'co_id': courseId,
          'threshold': threshold,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final weakTopicsList = data['weak_topics'] as List;
          print('✅ Found ${weakTopicsList.length} weak topics');

          return weakTopicsList
              .map((json) => WeakTopic.fromJson(json))
              .toList();
        }
      }

      print('⚠️ No weak topics data available');
      return [];
    } catch (e) {
      print('❌ Exception in getWeakTopics: $e');
      return [];
    }
  }

  /// Save quiz analysis for future recommendations
  ///
  /// This should be called after each quiz completion
  Future<bool> saveQuizAnalysis({
    required int userId,
    required int courseId,
    required List<QuizResult> quizResults,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/save_quiz_analysis');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserID': userId,
          'co_id': courseId,
          'quiz_results': quizResults.map((r) => r.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }

      return false;
    } catch (e) {
      print('❌ Exception in saveQuizAnalysis: $e');
      return false;
    }
  }

  /// Get overall topic performance statistics
  Future<Map<String, dynamic>?> getTopicPerformance({
    required int userId,
    required int courseId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get_topic_performance');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserID': userId,
          'co_id': courseId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data;
        }
      }

      return null;
    } catch (e) {
      print('❌ Exception in getTopicPerformance: $e');
      return null;
    }
  }
}
