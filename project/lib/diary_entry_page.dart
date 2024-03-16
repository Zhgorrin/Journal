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
  bool _isKeyboardVisible = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.initialText ?? '';
    if (widget.initialImages != null) {
      _images.addAll(widget.initialImages!);
    }
    _selectedMood = widget.initialMood;

    // Add listener to detect keyboard visibility
    _addListenerForKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.green[900],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diary Entry'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveEntry,
              color: Colors.green,
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
              color: Colors.blue,
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  if (widget.onDelete != null) {
                    widget.onDelete!();
                  }
                },
                color: Colors.red,
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: _isKeyboardVisible ? 100 : 300,
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  maxLines: null,
                  expands: true,
                  cursorColor: Colors.green[900],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Diary notes here',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[900]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[900]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[900]!,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showImageDialog(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(_images[index]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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

  void _showImageDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(_images[index]),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addListenerForKeyboard() {
    _focusNode.addListener(() {
      final isKeyboardOpen = _focusNode.hasFocus;
      if (isKeyboardOpen && !_isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = true;
        });
      } else if (!isKeyboardOpen && _isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = false;
        });
      }
    });
  }
}
