import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

// TODO: Add crash reporting service (Firebase Crashlytics, Sentry, etc.)
// TODO: Add analytics service (Firebase Analytics, Mixpanel, etc.)
// TODO: Add performance monitoring

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Firebase services
  // await Firebase.initializeApp();
  
  // TODO: Initialize crash reporting
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: RealityAnchorApp(),
    ),
  );
}

class RealityAnchorApp extends ConsumerStatefulWidget {
  const RealityAnchorApp({super.key});

  @override
  ConsumerState<RealityAnchorApp> createState() => _RealityAnchorAppState();
}

class _RealityAnchorAppState extends ConsumerState<RealityAnchorApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemeMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString('theme_mode') ?? 'system';
      
      setState(() {
        switch (savedThemeMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
      });
    } catch (e) {
      debugPrint('Failed to load theme mode: $e');
    }
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;
      
      switch (themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      await prefs.setString('theme_mode', themeModeString);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }

  void _toggleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
      }
    });
    
    _saveThemeMode(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reality Anchor',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      
      routerConfig: AppRouter.router,
      
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

}

class _ThemeToggleButton extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggle;

  const _ThemeToggleButton({
    required this.themeMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String tooltip;
    
    switch (themeMode) {
      case ThemeMode.system:
        icon = Icons.brightness_auto;
        tooltip = 'Auto theme';
        break;
      case ThemeMode.light:
        icon = Icons.light_mode;
        tooltip = 'Light theme';
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode;
        tooltip = 'Dark theme';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onToggle,
        icon: Icon(icon),
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

