import 'package:flutter/material.dart';

/// A reusable widget that displays Detective Gloop with a speech bubble
/// containing custom text. Perfect for game instructions and character dialogue.
class DetectiveSpeechBubble extends StatelessWidget {
  /// The text to display inside the speech bubble
  final String text;
  
  /// Optional text style override for the speech bubble text
  final TextStyle? textStyle;
  
  /// Padding inside the speech bubble area
  final EdgeInsetsGeometry padding;
  
  /// Optional width constraint for the widget
  final double? width;
  
  /// Optional height constraint for the widget
  final double? height;

  const DetectiveSpeechBubble({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsets.all(24),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    
    // Calculate responsive dimensions
    final bubbleWidth = width ?? screenSize.width * (isSmallScreen ? 0.95 : 0.8);
    final bubbleHeight = height ?? bubbleWidth * 0.75; // Maintain aspect ratio
    
    return Container(
      width: bubbleWidth,
      height: bubbleHeight,
      child: Stack(
        children: [
          // Background image with Detective Gloop and speech bubble
          Positioned.fill(
            child: Image.asset(
              'assets/images/characters/gloop_background_bubble.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Failed to load speech bubble image: $error');
                return _buildFallbackBubble(context, bubbleWidth, bubbleHeight);
              },
            ),
          ),
          
          // Text overlay positioned in the speech bubble area
          _buildTextOverlay(context, bubbleWidth, bubbleHeight, isSmallScreen),
        ],
      ),
    );
  }

  /// Builds the text overlay positioned within the speech bubble
  Widget _buildTextOverlay(BuildContext context, double bubbleWidth, double bubbleHeight, bool isSmallScreen) {
    // Calculate bubble text area positioning (adjust these values based on your actual bubble image)
    final bubbleTop = bubbleHeight * 0.15; // Top of speech bubble
    final bubbleLeft = bubbleWidth * 0.25; // Left edge of speech bubble
    final bubbleRight = bubbleWidth * 0.25; // Right edge of speech bubble
    final bubbleBottom = bubbleHeight * 0.45; // Bottom of speech bubble
    
    return Positioned(
      top: bubbleTop,
      left: bubbleLeft,
      right: bubbleRight,
      bottom: bubbleBottom,
      child: Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            text,
            style: _getEffectiveTextStyle(context, isSmallScreen),
            textAlign: TextAlign.left,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  /// Gets the effective text style, combining defaults with user overrides
  TextStyle _getEffectiveTextStyle(BuildContext context, bool isSmallScreen) {
    final defaultStyle = TextStyle(
      fontSize: isSmallScreen ? 16 : 18,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
      fontFamily: 'Comic',
      height: 1.3, // Line spacing
    );
    
    return textStyle != null ? defaultStyle.merge(textStyle) : defaultStyle;
  }

  /// Fallback UI when the background image fails to load
  Widget _buildFallbackBubble(BuildContext context, double bubbleWidth, double bubbleHeight) {
    return Container(
      width: bubbleWidth,
      height: bubbleHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Detective character placeholder
          Positioned(
            bottom: 0,
            left: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          
          // Speech bubble area
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 100,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  text,
                  style: _getEffectiveTextStyle(context, false),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example usage screen demonstrating the DetectiveSpeechBubble widget
class DetectiveSpeechBubbleExample extends StatelessWidget {
  const DetectiveSpeechBubbleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detective Speech Bubble Example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Detective Speech Bubble Examples',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Example 1: Basic usage
              const DetectiveSpeechBubble(
                text: "Welcome to Reality Anchor! I'm Detective Gloop, and I'll help you learn to spot what's real and what's fake!",
              ),
              
              const SizedBox(height: 32),
              
              // Example 2: Custom text style
              DetectiveSpeechBubble(
                text: "This mission will test your detective skills. Look carefully at each clue!",
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Example 3: Custom padding
              const DetectiveSpeechBubble(
                text: "Great job! You're becoming a real media literacy detective.",
                padding: EdgeInsets.all(32),
              ),
              
              const SizedBox(height: 32),
              
              // Example 4: Smaller bubble
              const DetectiveSpeechBubble(
                text: "Ready for the next challenge?",
                width: 280,
                height: 200,
                padding: EdgeInsets.all(16),
              ),
              
              const SizedBox(height: 32),
              
              // Interactive example
              _buildInteractiveExample(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveExample(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Interactive Example',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        DetectiveSpeechBubble(
          text: "Tap the button below to see me in action!",
          textStyle: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Detective Gloop says: Keep up the great detective work!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Talk to Detective Gloop'),
        ),
      ],
    );
  }
}

/*
USAGE EXAMPLES:

// Basic usage
DetectiveSpeechBubble(
  text: "Welcome to the mission!",
)

// With custom styling
DetectiveSpeechBubble(
  text: "Look for clues carefully!",
  textStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  padding: EdgeInsets.all(32),
)

// Responsive sizing
DetectiveSpeechBubble(
  text: "Great detective work!",
  width: 300,
  height: 250,
)

// In game instructions
class GameInstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DetectiveSpeechBubble(
          text: "Your mission: Find the fake news story among these headlines. Use your detective skills!",
          textStyle: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
*/