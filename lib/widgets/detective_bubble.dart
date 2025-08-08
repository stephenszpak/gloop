import 'package:flutter/material.dart';
import 'voiceover_bubble.dart';

/// A reusable widget that displays Detective Gloop with a magnifying glass
/// and speech bubble in the top portion. Designed for children's apps
/// with proper scaling to ensure text fits clearly within the speech bubble.
class DetectiveBubble extends StatefulWidget {
  /// The VoiceoverBubble widget to display (text goes in speech bubble, controls below image)
  final VoiceoverBubble voiceoverBubble;

  const DetectiveBubble({
    super.key,
    required this.voiceoverBubble,
  });

  @override
  State<DetectiveBubble> createState() => _DetectiveBubbleState();
}

class _DetectiveBubbleState extends State<DetectiveBubble> {
  final _voiceoverController = VoiceoverController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    // Calculate available height accounting for safe areas
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    
    // Use 60% of available height for the image, leaving room for controls below
    final imageHeight = availableHeight * 0.6;
    
    // Use 95% of screen width for better visibility
    final imageWidth = screenSize.width * 0.95;
    
    return SafeArea(
      child: Column(
        children: [
          // Detective Gloop image with text inside speech bubble
          Expanded(
            flex: 3,
            child: Center(
              child: _buildDetectiveBubbleWithText(context, imageWidth, imageHeight),
            ),
          ),
          
          // TTS Control buttons below the image
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.withOpacity(0.1), // Debug background
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _voiceoverController.buildControls(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectiveBubbleWithText(BuildContext context, double imageWidth, double imageHeight) {
    return SizedBox(
      width: imageWidth,
      height: imageHeight,
      child: Stack(
        children: [
          // Background image - sized to fill the container while preserving aspect ratio
          Positioned.fill(
            child: Image.asset(
              'assets/images/characters/gloop_speech_top.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Failed to load detective bubble image: $error');
                return _buildFallbackBubble(context, imageWidth, imageHeight);
              },
            ),
          ),
          
          // VoiceoverBubble positioned in the speech bubble area (top portion of image)
          _buildTextOverlay(context, imageWidth, imageHeight),
        ],
      ),
    );
  }

  /// Builds the text overlay positioned within the speech bubble area
  Widget _buildTextOverlay(BuildContext context, double imageWidth, double imageHeight) {
    // Calculate speech bubble positioning based on the image layout
    // The speech bubble is in the top-left portion of the image
    final speechBubbleTop = imageHeight * 0.05;    // 5% from top
    final speechBubbleLeft = imageWidth * 0.05;     // 5% from left  
    final speechBubbleWidth = imageWidth * 0.85;    // 85% of width
    final speechBubbleHeight = imageHeight * 0.45;  // 45% of height (upper portion)
    
    return Positioned(
      top: speechBubbleTop,
      left: speechBubbleLeft,
      child: SizedBox(
        width: speechBubbleWidth,
        height: speechBubbleHeight,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: VoiceoverBubble(
            text: widget.voiceoverBubble.text,
            baseStyle: widget.voiceoverBubble.baseStyle,
            highlightStyle: widget.voiceoverBubble.highlightStyle,
            wordDelayCalculator: widget.voiceoverBubble.wordDelayCalculator,
            autoStart: widget.voiceoverBubble.autoStart,
            onComplete: widget.voiceoverBubble.onComplete,
            controller: _voiceoverController,
          ),
        ),
      ),
    );
  }


  /// Fallback UI when the background image fails to load
  Widget _buildFallbackBubble(BuildContext context, double imageWidth, double maxImageHeight) {
    // Use the constrained max height for fallback
    final fallbackHeight = maxImageHeight.clamp(imageWidth * 0.6, imageWidth * 0.8);
    
    return Container(
      width: imageWidth,
      height: fallbackHeight,
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
          // Speech bubble area (top portion)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            height: fallbackHeight * 0.45, // Top 45% for speech bubble
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
              child: Align(
                alignment: Alignment.topLeft,
                child: VoiceoverBubble(
                  text: widget.voiceoverBubble.text,
                  baseStyle: widget.voiceoverBubble.baseStyle,
                  highlightStyle: widget.voiceoverBubble.highlightStyle,
                  wordDelayCalculator: widget.voiceoverBubble.wordDelayCalculator,
                  autoStart: widget.voiceoverBubble.autoStart,
                  onComplete: widget.voiceoverBubble.onComplete,
                  controller: _voiceoverController,
                ),
              ),
            ),
          ),
          
          // Detective character placeholder (bottom portion)
          Positioned(
            bottom: 20,
            left: imageWidth * 0.3,
            child: Container(
              width: imageWidth * 0.4,
              height: imageWidth * 0.4,
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
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.person_search,
                      size: imageWidth * 0.15,
                      color: Colors.white,
                    ),
                  ),
                  // Pointing up indicator
                  Positioned(
                    top: 10,
                    right: 15,
                    child: Icon(
                      Icons.arrow_upward,
                      size: imageWidth * 0.08,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
USAGE EXAMPLES:

// Basic usage with VoiceoverBubble
DetectiveBubble(
  voiceoverBubble: VoiceoverBubble(
    text: "Welcome to the mission!",
    baseStyle: TextStyle(fontSize: 16, color: Colors.teal),
    highlightStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
)

// With custom styling
DetectiveBubble(
  voiceoverBubble: VoiceoverBubble(
    text: "Look for clues carefully!",
    baseStyle: TextStyle(fontSize: 18, color: Colors.blue),
    highlightStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
  ),
)

// In a game screen - text appears in speech bubble, controls appear below image
class GameInstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectiveBubble(
        voiceoverBubble: VoiceoverBubble(
          text: "Your mission: Find the fake news story among these headlines!",
        ),
      ),
    );
  }
}
*/
