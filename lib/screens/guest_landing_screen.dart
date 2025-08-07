import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
    
    debugPrint('Guest login tapped - setting up guest session...');
    
    // Navigate to character introduction screen
    context.go('/character-intro');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Solid background color
      body: SafeArea(
        child: Column(
          children: [
            // Main content area with centered image
            Expanded(
              child: Center(
                child: _buildMainImage(screenSize),
              ),
            ),
            
            // Guest button at bottom
            _buildGuestButton(screenSize),
            
            // Bottom padding
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(Size screenSize) {
    // Calculate responsive image size
    final imageMaxWidth = screenSize.width * 0.8;
    final imageMaxHeight = screenSize.height * 0.6;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: imageMaxWidth,
        maxHeight: imageMaxHeight,
      ),
      child: Image.asset(
        'assets/images/pages/guest_login.png',
        fit: BoxFit.contain,
        semanticLabel: 'Detective Gloop with magnifying glass - Reality Anchor character',
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Failed to load main image: $error');
          return _buildFallbackMainImage();
        },
      ),
    );
  }

  Widget _buildFallbackMainImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Reality Anchor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Learn to spot real from fake!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton(Size screenSize) {
    // Responsive button width
    final buttonWidth = screenSize.width * 0.6;
    
    return AnimatedBuilder(
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
      child: GestureDetector(
        onTap: _onGuestLogin,
        child: Semantics(
          label: 'Play as guest button',
          hint: 'Tap to start playing Reality Anchor without creating an account',
          child: Container(
            width: buttonWidth,
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
                width: buttonWidth,
                fit: BoxFit.contain,
                semanticLabel: 'Play as guest',
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Failed to load guest button image: $error');
                  return _buildFallbackButton(buttonWidth);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackButton(double width) {
    return Container(
      width: width,
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
