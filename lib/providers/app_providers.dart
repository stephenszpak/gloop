import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_profile.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final selectedChildProvider = StateProvider<ChildProfile?>((ref) => null);

final childProfilesProvider = StateNotifierProvider<ChildProfilesNotifier, List<ChildProfile>>((ref) {
  return ChildProfilesNotifier();
});

final currentMissionProvider = StateNotifierProvider<CurrentMissionNotifier, AsyncValue<Mission?>>((ref) {
  return CurrentMissionNotifier(ref.read(apiServiceProvider));
});

final missionTimerProvider = StateNotifierProvider<MissionTimerNotifier, Duration>((ref) {
  return MissionTimerNotifier();
});

class ChildProfilesNotifier extends StateNotifier<List<ChildProfile>> {
  ChildProfilesNotifier() : super(_mockProfiles);

  static final List<ChildProfile> _mockProfiles = [
    ChildProfile(
      id: '1',
      name: 'Emma',
      avatarEmoji: '🦄',
      completedMissions: 15,
      correctAnswers: 12,
    ),
    ChildProfile(
      id: '2',
      name: 'Alex',
      avatarEmoji: '🚀',
      completedMissions: 8,
      correctAnswers: 6,
    ),
    ChildProfile(
      id: '3',
      name: 'Sam',
      avatarEmoji: '🌟',
      completedMissions: 22,
      correctAnswers: 19,
    ),
  ];

  void updateProgress(String childId, bool isCorrect) {
    state = state.map((child) {
      if (child.id == childId) {
        return child.copyWith(
          completedMissions: child.completedMissions + 1,
          correctAnswers: child.correctAnswers + (isCorrect ? 1 : 0),
          lastPlayedDate: DateTime.now(),
        );
      }
      return child;
    }).toList();
  }
}

class CurrentMissionNotifier extends StateNotifier<AsyncValue<Mission?>> {
  CurrentMissionNotifier(this._apiService) : super(const AsyncValue.data(null));
  
  final ApiService _apiService;
  int _missionCounter = 0;

  Future<void> loadNextMission(String childId, int difficultyLevel) async {
    state = const AsyncValue.loading();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final mission = _apiService.createMockMission(_missionCounter++);
      state = AsyncValue.data(mission);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearMission() {
    state = const AsyncValue.data(null);
  }
}

class MissionTimerNotifier extends StateNotifier<Duration> {
  MissionTimerNotifier() : super(Duration.zero);
  
  DateTime? _startTime;

  void startTimer() {
    _startTime = DateTime.now();
    state = Duration.zero;
  }

  Duration stopTimer() {
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      state = elapsed;
      return elapsed;
    }
    return Duration.zero;
  }

  void resetTimer() {
    _startTime = null;
    state = Duration.zero;
  }
}