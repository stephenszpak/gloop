class Mission {
  final String id;
  final String type;
  final String imageUrl;
  final String questionText;
  final bool correctAnswer;
  final String explanation;
  final int difficultyLevel;

  Mission({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.questionText,
    required this.correctAnswer,
    required this.explanation,
    this.difficultyLevel = 1,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as bool,
      explanation: json['explanation'] as String,
      difficultyLevel: json['difficultyLevel'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'imageUrl': imageUrl,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficultyLevel': difficultyLevel,
    };
  }
}