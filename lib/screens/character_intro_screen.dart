import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/detective_bubble.dart';
import '../widgets/voiceover_bubble.dart';
import '../theme/app_theme.dart';

class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GloopColors.warmBeige,
      body: SafeArea(
        child: Stack(
          children: [
            // Detective Bubble with voiceover - now includes controls below image
            DetectiveBubble(
              voiceoverBubble: VoiceoverBubble(
                text: "Hi there! I'm Detective Gloop, your media literacy guide! I help kids like you learn to spot what's real and what's fake. Are you ready to become a super detective and play some exciting missions?",
                baseStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: GloopColors.darkTeal,
                  height: 1.2,
                ),
                highlightStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GloopColors.deepTeal,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: GloopColors.mustardYellow,
                      blurRadius: 1,
                      offset: Offset(0.6, 0.6),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
