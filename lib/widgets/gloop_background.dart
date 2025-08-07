import 'package:flutter/material.dart';

class GloopBackground extends StatelessWidget {
  final Widget child;
  final BoxFit fit;

  const GloopBackground({
    super.key,
    required this.child,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/characters/gloop_main_body.png',
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Failed to load Gloop background image: $error');
                return _buildFallbackBackground(context);
              },
            ),
          ),
          // Child content with SafeArea
          SafeArea(
            child: Center(
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            Theme.of(context).colorScheme.background,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bubble_chart,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gloop Background',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
