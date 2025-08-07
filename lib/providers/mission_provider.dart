import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

// TODO: Replace with actual mission service integration
class MissionService {
  static const Duration _mockDelay = Duration(milliseconds: 800);
  static final Random _random = Random();
  
  // TODO: Replace with actual API endpoint
  Future<Mission> fetchNextMission(String childId, int difficultyLevel) async {
    await Future.delayed(_mockDelay);
    
    // Mock mission generation
    final missionId = 'mission_${DateTime.now().millisecondsSinceEpoch}';
    final isReal = _random.nextBool();
    final imageIndex = _random.nextInt(20) + 1;
    
    final mockMissions = [
      {
        'type': 'photo_verification',
        'questionText': 'Is this a real photo or created by AI? 🤔',
        'realExplanation': '✅ This is a real photo! You can tell because the lighting looks natural and the details are consistent.',
        'fakeExplanation': '❌ This was created by AI! Look for unnatural lighting, weird textures, or impossible details.',
      },
      {
        'type': 'deepfake_detection',
        'questionText': 'Does this person look real to you? 👤',
        'realExplanation': '✅ This is a real person! Their facial features and expressions look natural.',
        'fakeExplanation': '❌ This is a deepfake! AI-generated faces often have subtle inconsistencies in skin texture or eye movements.',
      },
      {
        'type': 'news_verification',
        'questionText': 'Could this news story be real? 📰',
        'realExplanation': '✅ This appears to be from a reliable news source with factual reporting.',
        'fakeExplanation': '❌ This looks like fake news! Always check if the source is trustworthy and look for evidence.',
      },
      {
        'type': 'social_media_post',
        'questionText': 'Is this social media post showing something real? 📱',
        'realExplanation': '✅ This post shows a real event with verified information.',
        'fakeExplanation': '❌ This post contains misleading information! Be careful of posts that seem too crazy to be true.',
      },
    ];
    
    final selectedMission = mockMissions[_random.nextInt(mockMissions.length)];
    
    return Mission(
      id: missionId,
      type: selectedMission['type']!,
      imageUrl: 'https://picsum.photos/400/300?random=$imageIndex',
      questionText: selectedMission['questionText']!,
      correctAnswer: isReal,
      explanation: isReal 
          ? selectedMission['realExplanation']!
          : selectedMission['fakeExplanation']!,
      difficultyLevel: difficultyLevel,
    );
  }

  // TODO: Replace with actual API endpoint for result submission
  Future<void> submitMissionResult({
    required String missionId,
    required String childId,
    required bool userAnswer,
    required bool correctAnswer,
    required Duration timeSpent,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock result submission - in real app, this would send to backend
    print('Mission Result Submitted:');
    print('  Mission ID: $missionId');
    print('  Child ID: $childId');
    print('  User Answer: $userAnswer');
    print('  Correct Answer: $correctAnswer');
    print('  Is Correct: ${userAnswer == correctAnswer}');
    print('  Time Spent: ${timeSpent.inSeconds}s');
  }

  // TODO: Implement actual streak tracking
  Future<int> getCurrentStreak(String childId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock streak data
    return _random.nextInt(10);
  }

  // TODO: Implement actual daily progress tracking
  Future<Map<String, int>> getDailyProgress(String childId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Mock daily progress - last 7 days
    final now = DateTime.now();
    final progress = <String, int>{};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      progress[dateKey] = _random.nextInt(8); // 0-7 missions per day
    }
    
    return progress;
  }
}

class MissionException implements Exception {
  final String message;
  MissionException(this.message);
  
  @override
  String toString() => 'MissionException: $message';
}

enum MissionStatus {
  idle,
  loading,
  loaded,
  submitting,
  completed,
  error,
}

class MissionState {
  final MissionStatus status;
  final Mission? currentMission;
  final bool? userAnswer;
  final Duration? timeSpent;
  final String? errorMessage;
  final DateTime? startTime;
  final int currentStreak;

  MissionState({
    this.status = MissionStatus.idle,
    this.currentMission,
    this.userAnswer,
    this.timeSpent,
    this.errorMessage,
    this.startTime,
    this.currentStreak = 0,
  });

  MissionState copyWith({
    MissionStatus? status,
    Mission? currentMission,
    bool? userAnswer,
    Duration? timeSpent,
    String? errorMessage,
    DateTime? startTime,
    int? currentStreak,
  }) {
    return MissionState(
      status: status ?? this.status,
      currentMission: currentMission ?? this.currentMission,
      userAnswer: userAnswer ?? this.userAnswer,
      timeSpent: timeSpent ?? this.timeSpent,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  bool get isCorrect => 
      currentMission != null && 
      userAnswer != null && 
      userAnswer == currentMission!.correctAnswer;
}

class MissionNotifier extends StateNotifier<MissionState> {
  MissionNotifier(this._missionService) : super(MissionState());

  final MissionService _missionService;

  Future<void> loadNextMission(String childId, {int difficultyLevel = 1}) async {
    try {
      state = state.copyWith(
        status: MissionStatus.loading,
        errorMessage: null,
        userAnswer: null,
        timeSpent: null,
        startTime: DateTime.now(),
      );

      final mission = await _missionService.fetchNextMission(childId, difficultyLevel);
      final streak = await _missionService.getCurrentStreak(childId);

      state = state.copyWith(
        status: MissionStatus.loaded,
        currentMission: mission,
        currentStreak: streak,
      );
    } catch (e) {
      state = state.copyWith(
        status: MissionStatus.error,
        errorMessage: e.toString().replaceFirst('MissionException: ', ''),
      );
    }
  }

  void submitAnswer(bool answer, String childId) async {
    if (state.currentMission == null) return;

    try {
      final startTime = state.startTime ?? DateTime.now();
      final timeSpent = DateTime.now().difference(startTime);

      state = state.copyWith(
        status: MissionStatus.submitting,
        userAnswer: answer,
        timeSpent: timeSpent,
      );

      await _missionService.submitMissionResult(
        missionId: state.currentMission!.id,
        childId: childId,
        userAnswer: answer,
        correctAnswer: state.currentMission!.correctAnswer,
        timeSpent: timeSpent,
      );

      // Update streak based on correctness
      final newStreak = state.isCorrect ? state.currentStreak + 1 : 0;

      state = state.copyWith(
        status: MissionStatus.completed,
        currentStreak: newStreak,
      );
    } catch (e) {
      state = state.copyWith(
        status: MissionStatus.error,
        errorMessage: e.toString().replaceFirst('MissionException: ', ''),
      );
    }
  }

  void resetMission() {
    state = MissionState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class DailyProgressNotifier extends StateNotifier<Map<String, int>> {
  DailyProgressNotifier(this._missionService) : super({});

  final MissionService _missionService;

  Future<void> loadDailyProgress(String childId) async {
    try {
      final progress = await _missionService.getDailyProgress(childId);
      state = progress;
    } catch (e) {
      // Handle error silently for progress data
      state = {};
    }
  }
}

// Providers
final missionServiceProvider = Provider<MissionService>((ref) {
  return MissionService();
});

final missionProvider = StateNotifierProvider<MissionNotifier, MissionState>((ref) {
  final missionService = ref.watch(missionServiceProvider);
  return MissionNotifier(missionService);
});

final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, Map<String, int>>((ref) {
  final missionService = ref.watch(missionServiceProvider);
  return DailyProgressNotifier(missionService);
});

// Computed providers
final currentMissionProvider = Provider<Mission?>((ref) {
  final missionState = ref.watch(missionProvider);
  return missionState.currentMission;
});

final missionStatusProvider = Provider<MissionStatus>((ref) {
  final missionState = ref.watch(missionProvider);
  return missionState.status;
});

final isCorrectAnswerProvider = Provider<bool?>((ref) {
  final missionState = ref.watch(missionProvider);
  if (missionState.userAnswer == null || missionState.currentMission == null) {
    return null;
  }
  return missionState.isCorrect;
});

final currentStreakProvider = Provider<int>((ref) {
  final missionState = ref.watch(missionProvider);
  return missionState.currentStreak;
});