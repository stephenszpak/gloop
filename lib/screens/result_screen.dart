import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final bool userAnswer;
  final Duration timeSpent;

  const ResultScreen({
    super.key,
    required this.userAnswer,
    required this.timeSpent,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;
  
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    _processResult();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _processResult() async {
    final mission = ref.read(currentMissionProvider).value;
    final selectedChild = ref.read(selectedChildProvider);
    
    if (mission != null && selectedChild != null) {
      _isCorrect = widget.userAnswer == mission.correctAnswer;
      
      ref.read(childProfilesProvider.notifier).updateProgress(
        selectedChild.id,
        _isCorrect!,
      );
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      _fadeController.forward();
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      _bounceController.forward();
      
      if (_isCorrect!) {
        _confettiController.forward();
      }
    }
  }

  void _nextMission() {
    ref.read(currentMissionProvider.notifier).clearMission();
    context.go('/mission');
  }

  void _viewProgress() {
    context.go('/progress');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mission = ref.watch(currentMissionProvider).value;
    final selectedChild = ref.watch(selectedChildProvider);
    
    if (mission == null || _isCorrect == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isCorrect!)
              AnimatedBuilder(
                animation: _confettiAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(_confettiAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),
            
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    ScaleTransition(
                      scale: _bounceAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: (_isCorrect! 
                              ? Colors.green 
                              : Colors.orange
                          ).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isCorrect! 
                              ? Icons.check_circle
                              : Icons.info_outline,
                          size: 80,
                          color: _isCorrect! 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      _isCorrect! ? 'Correct! 🎉' : 'Not quite! 🤔',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isCorrect! 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _isCorrect! 
                          ? 'Great detective work, ${selectedChild?.name}!' 
                          : 'Keep learning, ${selectedChild?.name}!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Learning Time!',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            mission.explanation,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            theme,
                            'Your Answer',
                            widget.userAnswer ? 'REAL 📸' : 'FAKE 🤖',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildStatColumn(
                            theme,
                            'Correct Answer',
                            mission.correctAnswer ? 'REAL 📸' : 'FAKE 🤖',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildStatColumn(
                            theme,
                            'Time Taken',
                            '${widget.timeSpent.inSeconds}s',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _viewProgress,
                            icon: const Icon(Icons.analytics),
                            label: const Text('View Progress'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nextMission,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next Mission'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    TextButton.icon(
                      onPressed: () => context.go('/children'),
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onBackground.withOpacity(0.7),
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

  Widget _buildStatColumn(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  
  ConfettiPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint();
    final colors = [
      Colors.yellow,
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
    for (int i = 0; i < 30; i++) {
      final x = (i * 37.5) % size.width;
      final y = (progress * size.height * 1.2) - (i * 20);
      
      if (y > 0 && y < size.height) {
        paint.color = colors[i % colors.length];
        canvas.drawCircle(
          Offset(x, y),
          4,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}