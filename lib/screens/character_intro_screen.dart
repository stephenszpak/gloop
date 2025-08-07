import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/detective_bubble.dart';
import '../theme/app_theme.dart';

class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GloopColors.warmBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Detective Bubble taking up most of the screen
            Expanded(
              flex: 3,
              child: DetectiveBubble(
                text: "Hi there! I'm Detective Gloop, your media literacy guide! I help kids like you learn to spot what's real and what's fake. Are you ready to become a super detective and play some exciting missions?",
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GloopColors.darkTeal,
                  height: 1.4,
                ),
              ),
            ),
            
            // Action buttons at bottom
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Primary action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _selectMission(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GloopColors.mustardYellow,
                          foregroundColor: GloopColors.darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 8,
                          shadowColor: GloopColors.deepTeal.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Select Mission',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: GloopColors.darkTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Secondary back button
                    TextButton(
                      onPressed: () => _goBack(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        'Back to Start',
                        style: TextStyle(
                          color: GloopColors.deepTeal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _selectMission(BuildContext context) {
    debugPrint('Select Mission tapped - navigating to mission selection...');
    context.go('/mission-select');
  }

  void _goBack(BuildContext context) {
    context.go('/');
  }
}