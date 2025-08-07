import 'package:flutter/material.dart';

/// A reusable widget that displays Detective Gloop with a speech bubble
/// containing custom text. Designed specifically for children's apps with
/// proper scaling and responsive text layout.
class DetectiveBubble extends StatelessWidget {
  /// The text to display inside the speech bubble
  final String text;
  
  /// Optional text style override
  final TextStyle? textStyle;
  
  /// Optional constraints for the text bubble area
  final BoxConstraints? bubbleConstraints;
  
  /// Optional padding around the entire widget
  final EdgeInsetsGeometry? padding;

  const DetectiveBubble({
    super.key,
    required this.text,
    this.textStyle,
    this.bubbleConstraints,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    // Calculate available space accounting for safe areas
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    
    // Apply consistent margin (5-10% padding on all sides)
    final margin = EdgeInsets.symmetric(
      horizontal: availableWidth * 0.05,
      vertical: availableHeight * 0.05,
    );
    
    return Padding(
      padding: padding ?? margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AspectRatio(
            // Adjust this ratio based on your actual image dimensions
            // This assumes the image is roughly 4:3 (width:height)
            aspectRatio: 4 / 3,
            child: Container(
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  // Background image with proper scaling
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/characters/gloop_background_bubble.png',
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Failed to load detective bubble image: $error');
                          return _buildFallbackBubble(context, constraints);
                        },
                      ),
                    ),
                  ),
                  
                  // Text overlay positioned in the speech bubble
                  _buildTextOverlay(context, constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the text overlay positioned within the speech bubble area
  Widget _buildTextOverlay(BuildContext context, BoxConstraints constraints) {
    // Calculate bubble text area positioning
    // These percentages should be adjusted based on your actual image layout
    final bubbleWidth = constraints.maxWidth;
    final bubbleHeight = constraints.maxWidth / (4/3); // Maintain aspect ratio
    
    // Position the text in the upper portion of the bubble
    // Adjust these values based on where the speech bubble appears in your image
    final textTop = bubbleHeight * 0.15;    // 15% from top
    final textLeft = bubbleWidth * 0.2;     // 20% from left
    final textWidth = bubbleWidth * 0.6;    // 60% of total width
    final textHeight = bubbleHeight * 0.35;  // 35% of total height
    
    return Positioned(
      top: textTop,
      left: textLeft,
      child: Container(
        width: textWidth,
        height: textHeight,
        constraints: bubbleConstraints ?? BoxConstraints(
          maxWidth: textWidth,
          maxHeight: textHeight,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              text,
              style: _getEffectiveTextStyle(context, bubbleWidth),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

  /// Gets the effective text style with responsive sizing
  TextStyle _getEffectiveTextStyle(BuildContext context, double bubbleWidth) {
    // Calculate responsive font size based on bubble width
    final baseFontSize = (bubbleWidth * 0.045).clamp(16.0, 24.0);
    
    final defaultStyle = TextStyle(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF004B4B),
      height: 1.4, // Good line spacing for readability
      fontFamily: 'Comic',
    );
    
    return textStyle != null ? defaultStyle.merge(textStyle) : defaultStyle;
  }

  /// Fallback UI when the background image fails to load
  Widget _buildFallbackBubble(BuildContext context, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxWidth / (4/3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF38B3AC).withOpacity(0.1),
            const Color(0xFFFDF3DE),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF157C84),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Detective character placeholder
          Positioned(
            bottom: 20,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF38B3AC),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_search,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          
          // Speech bubble area
          Positioned(
            top: 30,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF157C84),
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
              child: Text(
                text,
                style: _getEffectiveTextStyle(context, constraints.maxWidth),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example usage screen demonstrating the DetectiveBubble widget
class DetectiveBubbleExample extends StatelessWidget {
  const DetectiveBubbleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DE),
      appBar: AppBar(
        title: const Text('Detective Bubble Example'),
        backgroundColor: const Color(0xFF157C84),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Main example
              const DetectiveBubble(
                text: "Hi there! I'm Detective Gloop, your media literacy guide! I help kids like you learn to spot what's real and what's fake. Are you ready to become a super detective and play some exciting games?",
              ),
              
              const SizedBox(height: 20),
              
              // Smaller example with custom styling
              DetectiveBubble(
                text: "Great job! You're becoming a real detective.",
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C4D),
                ),
                padding: const EdgeInsets.all(10),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detective Gloop says: Keep learning!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE1B94A),
                      foregroundColor: const Color(0xFF0F4C4D),
                    ),
                    child: const Text('Continue'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF157C84),
                      side: const BorderSide(color: Color(0xFF157C84)),
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
USAGE EXAMPLES:

// Basic usage
DetectiveBubble(
  text: "Welcome to the mission!",
)

// With custom text styling
DetectiveBubble(
  text: "Look for clues carefully!",
  textStyle: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)

// With custom constraints and padding
DetectiveBubble(
  text: "Great detective work!",
  bubbleConstraints: BoxConstraints(
    maxWidth: 200,
    maxHeight: 100,
  ),
  padding: EdgeInsets.all(20),
)

// In a game screen
class GameInstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DetectiveBubble(
            text: "Your mission: Find the fake news story among these headlines!",
          ),
          // ... rest of your game UI
        ],
      ),
    );
  }
}

// Responsive usage in different orientations
class ResponsiveDetectiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return DetectiveBubble(
            text: "I adapt to any screen size and orientation!",
            padding: EdgeInsets.all(
              orientation == Orientation.portrait ? 16.0 : 8.0,
            ),
          );
        },
      ),
    );
  }
}
*/