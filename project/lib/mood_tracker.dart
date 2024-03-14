import 'package:flutter/material.dart';

class MoodTracker extends StatefulWidget {
  final int initialMood;
  final Function(int) onMoodSelected;

  const MoodTracker(
      {super.key, required this.initialMood, required this.onMoodSelected});

  @override
  _MoodTrackerState createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  late int _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('How do you feel today?'),
        Slider(
          value: _selectedMood.toDouble(),
          min: 0,
          max: 4,
          divisions: 4,
          onChanged: (newValue) {
            setState(() {
              _selectedMood = newValue.toInt();
            });
            widget.onMoodSelected(_selectedMood);
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('😢'),
            Text('😞'),
            Text('😐'),
            Text('😊'),
            Text('😄'),
          ],
        ),
      ],
    );
  }
}
