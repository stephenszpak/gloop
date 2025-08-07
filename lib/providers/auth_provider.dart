import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/child_profile.dart';

// TODO: Replace with actual auth service integration
class AuthService {
  static const Duration _mockDelay = Duration(seconds: 1);

  // TODO: Implement actual backend authentication
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(_mockDelay);
    
    // Mock validation - accept any email with password length > 6
    if (email.contains('@') && password.length >= 6) {
      return User(
        id: 'user_${email.hashCode}',
        email: email,
        name: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        childrenIds: ['child_1', 'child_2', 'child_3'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );
    }
    
    throw AuthException('Invalid email or password');
  }

  // TODO: Implement actual backend logout
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // TODO: Implement actual password reset
  Future<void> resetPassword(String email) async {
    await Future.delayed(_mockDelay);
    
    if (!email.contains('@')) {
      throw AuthException('Invalid email address');
    }
  }

  // TODO: Implement actual token refresh
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock: return null (not authenticated)
    return null;
  }

  // TODO: Implement actual children fetching
  Future<List<ChildProfile>> getChildrenForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock children data
    return [
      ChildProfile(
        id: 'child_1',
        name: 'Emma',
        avatarEmoji: '🦄',
        completedMissions: 15,
        correctAnswers: 12,
        lastPlayedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChildProfile(
        id: 'child_2',
        name: 'Alex',
        avatarEmoji: '🚀',
        completedMissions: 8,
        correctAnswers: 6,
        lastPlayedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChildProfile(
        id: 'child_3',
        name: 'Sam',
        avatarEmoji: '🌟',
        completedMissions: 22,
        correctAnswers: 19,
        lastPlayedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState.initial) {
    _checkAuthStatus();
  }

  final AuthService _authService;
  User? _currentUser;
  List<ChildProfile> _children = [];
  String? _errorMessage;

  User? get currentUser => _currentUser;
  List<ChildProfile> get children => _children;
  String? get errorMessage => _errorMessage;

  Future<void> _checkAuthStatus() async {
    try {
      state = AuthState.loading;
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        _currentUser = user;
        _children = await _authService.getChildrenForUser(user.id);
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      state = AuthState.error;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      state = AuthState.loading;
      _errorMessage = null;
      
      final user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        _currentUser = user;
        _children = await _authService.getChildrenForUser(user.id);
        state = AuthState.authenticated;
        return true;
      } else {
        state = AuthState.unauthenticated;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('AuthException: ', '');
      state = AuthState.error;
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      state = AuthState.loading;
      await _authService.signOut();
      
      _currentUser = null;
      _children = [];
      _errorMessage = null;
      state = AuthState.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      state = AuthState.error;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('AuthException: ', '');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
  }

  void updateChildProgress(String childId, bool isCorrect) {
    final childIndex = _children.indexWhere((child) => child.id == childId);
    if (childIndex != -1) {
      final child = _children[childIndex];
      _children[childIndex] = child.copyWith(
        completedMissions: child.completedMissions + 1,
        correctAnswers: child.correctAnswers + (isCorrect ? 1 : 0),
        lastPlayedDate: DateTime.now(),
      );
      
      // Trigger state update
      final currentState = state;
      state = AuthState.loading;
      state = currentState;
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<User?>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.currentUser;
});

final childrenProvider = Provider<List<ChildProfile>>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.children;
});

final authErrorProvider = Provider<String?>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.errorMessage;
});