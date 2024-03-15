import 'package:flutter/material.dart';

class MoodTracker extends StatefulWidget {
  final int initialMood;
  final Function(int) onMoodSelected;

  const MoodTracker({
    super.key,
    required this.initialMood,
    required this.onMoodSelected,
  });

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
        const Text('How do you feel today?', style: TextStyle(fontSize: 18)),
        Slider(
          value: _selectedMood.toDouble(),
          min: 0,
          max: 4,
          divisions: 4,
          activeColor: _getMoodColor(_selectedMood),
          onChanged: (newValue) {
            setState(() {
              _selectedMood = newValue.toInt();
            });
            widget.onMoodSelected(_selectedMood);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMoodIcon('😢', 0),
            _buildMoodIcon('😞', 1),
            _buildMoodIcon('😐', 2),
            _buildMoodIcon('😊', 3),
            _buildMoodIcon('😄', 4),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodIcon(String icon, int moodIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = moodIndex;
        });
        widget.onMoodSelected(_selectedMood);
      },
      child: Text(
        icon,
        style: TextStyle(
          fontSize: 30,
          color: _selectedMood == moodIndex
              ? _getMoodColor(moodIndex)
              : Colors.grey,
        ),
      ),
    );
  }

  Color _getMoodColor(int moodIndex) {
    switch (moodIndex) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
