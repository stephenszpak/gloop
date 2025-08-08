import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MissionType {
  final String type;
  final String label;

  const MissionType({
    required this.type,
    required this.label,
  });
}

class MissionTypeSelectScreen extends StatelessWidget {
  const MissionTypeSelectScreen({super.key});

  static const List<MissionType> missionTypes = [
    MissionType(type: "spot_the_silly_thing", label: "Spot the Silly Thing"),
  ];

  void _onSelect(BuildContext context, String type) {
    debugPrint('Selected mission type: $type');
    
    // Navigate to Spot the Silly Thing game with a random challenge
    if (type == 'spot_the_silly_thing') {
      _navigateToRandomChallenge(context);
    }
  }

  void _navigateToRandomChallenge(BuildContext context) async {
    try {
      // Get a random challenge ID from the API
      final response = await http.get(
        Uri.parse('http://localhost:4000/api/v1/silly_challenges/random'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final challengeId = data['data']['id'].toString();
        context.go('/silly-thing-game/$challengeId');
      } else {
        // Fallback to a known challenge if API fails
        context.go('/silly-thing-game/2');
      }
    } catch (e) {
      // Fallback to a known challenge if network fails
      context.go('/silly-thing-game/2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Mission'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return _buildPortraitLayout();
            } else {
              return _buildLandscapeLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a mission type to start learning!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: missionTypes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final missionType = missionTypes[index];
                return _buildMissionButton(context, missionType);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Pick a mission type to start learning!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: missionTypes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final missionType = missionTypes[index];
                return SizedBox(
                  width: 280,
                  child: _buildMissionButton(context, missionType),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionButton(BuildContext context, MissionType missionType) {
    return Semantics(
      label: '${missionType.label} mission button',
      hint: 'Tap to start ${missionType.label} missions',
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => _onSelect(context, missionType.type),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: _buildTextButton(context, missionType),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, MissionType missionType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getMissionIcon(missionType.type),
                size: 32,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                missionType.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMissionIcon(String type) {
    switch (type) {
      case 'spot_the_silly_thing':
        return Icons.emoji_emotions;
      default:
        return Icons.quiz;
    }
  }
}