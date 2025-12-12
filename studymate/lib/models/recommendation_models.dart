/// Models for the AI Recommendation System
/// Matches backend API structure at /Recommendation endpoint

/// Represents a single recommendation from the AI system
class RecommendationItem {
  final int lecture;
  final String topic;
  final double accuracy;
  final String recommendation;

  RecommendationItem({
    required this.lecture,
    required this.topic,
    required this.accuracy,
    required this.recommendation,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      lecture: json['lecture'] as int,
      topic: json['topic'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lecture': lecture,
      'topic': topic,
      'accuracy': accuracy,
      'recommendation': recommendation,
    };
  }
}

/// Request body for the recommendation endpoint
class RecommendationRequest {
  final List<List<dynamic>> links; // [[path, lecture_num], ...]
  final List<QuizResult> quizResults;

  RecommendationRequest({
    required this.links,
    required this.quizResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'links': links,
      'quiz_results': quizResults.map((r) => r.toJson()).toList(),
    };
  }
}

/// Single quiz result with topic information
class QuizResult {
  final String lecture;
  final String topic;
  final int correct; // 1 for correct, 0 for incorrect

  QuizResult({
    required this.lecture,
    required this.topic,
    required this.correct,
  });

  Map<String, dynamic> toJson() {
    return {
      'Lecture': lecture,
      'Topic': topic,
      'Correct': correct,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      lecture: json['Lecture'] as String,
      topic: json['Topic'] as String,
      correct: json['Correct'] as int,
    );
  }
}

/// Response from the recommendation endpoint
class RecommendationResponse {
  final List<RecommendationItem> recommendations;

  RecommendationResponse({required this.recommendations});

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    var list = json['recommendations'] as List;
    List<RecommendationItem> recommendations =
        list.map((i) => RecommendationItem.fromJson(i)).toList();
    return RecommendationResponse(recommendations: recommendations);
  }
}

/// Weak topic from /get_weak_topics endpoint
class WeakTopic {
  final String topic;
  final List<String> lectures;
  final int correctCount;
  final int totalCount;
  final double accuracy;
  final List<String> relatedTopics;

  WeakTopic({
    required this.topic,
    required this.lectures,
    required this.correctCount,
    required this.totalCount,
    required this.accuracy,
    required this.relatedTopics,
  });

  factory WeakTopic.fromJson(Map<String, dynamic> json) {
    return WeakTopic(
      topic: json['topic'] as String,
      lectures: List<String>.from(json['lectures'] as List),
      correctCount: json['correct_count'] as int,
      totalCount: json['total_count'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      relatedTopics: List<String>.from(json['related_topics'] as List),
    );
  }
}
