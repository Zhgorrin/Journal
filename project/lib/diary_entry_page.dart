import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'mood_tracker.dart';

class DiaryEntryPage extends StatefulWidget {
  final String? initialText;
  final List<File>? initialImages;
  final int initialMood;
  final Function(String, List<File>, int) onUpdate;
  final VoidCallback? onDelete;

  const DiaryEntryPage({
    super.key,
    this.initialText,
    this.initialImages,
    required this.initialMood,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<File> _images = [];
  late int _selectedMood;

  @override
  initState() {
    super.initState();
    _textEditingController.text = widget.initialText ?? '';
    if (widget.initialImages != null) {
      _images.addAll(widget.initialImages!);
    }
    _selectedMood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveEntry();
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              _pickImage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Diary notes here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(_images[index]),
                  );
                },
              ),
            ),
            MoodTracker(
              initialMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    String entryText = _textEditingController.text;
    widget.onUpdate(entryText, _images, _selectedMood);
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
