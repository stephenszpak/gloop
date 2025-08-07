import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuestLandingScreen extends StatefulWidget {
  const GuestLandingScreen({super.key});

  @override
  State<GuestLandingScreen> createState() => _GuestLandingScreenState();
}

class _GuestLandingScreenState extends State<GuestLandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize button animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Start animation after a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onGuestLogin() {
    // Add haptic feedback for better user experience
    HapticFeedback.lightImpact();
    
    // TODO: Implement guest session setup and navigation
    // This will later navigate to MissionTypeSelectScreen
    debugPrint('Guest login tapped - setting up guest session...');
    
    // Placeholder navigation for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Starting guest session...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            _buildBackgroundImage(),
            
            // Guest Button positioned at bottom
            _buildGuestButton(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/pages/landing_page_v1.png',
        fit: BoxFit.cover,
        semanticLabel: 'Reality Anchor welcome background',
        errorBuilder: (context, error, stackTrace) {
          // Fallback gradient background if image fails to load
          debugPrint('Failed to load background image: $error');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
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
                    Icons.anchor,
                    size: 80,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reality Anchor',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn to spot real from fake!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestButton(bool isSmallScreen) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: isSmallScreen ? 20 : 40,
      child: AnimatedBuilder(
        animation: Listenable.merge([_buttonScaleAnimation, _buttonFadeAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Opacity(
              opacity: _buttonFadeAnimation.value,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _buildGuestButtonContent(),
        ),
      ),
    );
  }

  Widget _buildGuestButtonContent() {
    return GestureDetector(
      onTap: _onGuestLogin,
      child: Semantics(
        label: 'Play as guest button',
        hint: 'Tap to start playing Reality Anchor without creating an account',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/buttons/play_as_guest.png',
              height: 64,
              fit: BoxFit.contain,
              semanticLabel: 'Play as guest',
              errorBuilder: (context, error, stackTrace) {
                // Fallback button if image fails to load
                debugPrint('Failed to load guest button image: $error');
                return _buildFallbackButton();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackButton() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Play as Guest',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}