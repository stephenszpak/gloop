class ChildProfile {
  final String id;
  final String name;
  final String avatarEmoji;
  final int completedMissions;
  final int correctAnswers;
  final DateTime lastPlayedDate;

  ChildProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    this.completedMissions = 0,
    this.correctAnswers = 0,
    DateTime? lastPlayedDate,
  }) : lastPlayedDate = lastPlayedDate ?? DateTime.now();

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarEmoji: json['avatarEmoji'] as String,
      completedMissions: json['completedMissions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      lastPlayedDate: DateTime.parse(json['lastPlayedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarEmoji': avatarEmoji,
      'completedMissions': completedMissions,
      'correctAnswers': correctAnswers,
      'lastPlayedDate': lastPlayedDate.toIso8601String(),
    };
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    String? avatarEmoji,
    int? completedMissions,
    int? correctAnswers,
    DateTime? lastPlayedDate,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      completedMissions: completedMissions ?? this.completedMissions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }
}