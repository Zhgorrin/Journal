import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DiaryEntryPage extends StatefulWidget {
  final String? initialText;
  final List<File>? initialImages;
  final Function(String, List<File>) onUpdate;
  final VoidCallback? onDelete;

  const DiaryEntryPage({
    Key? key,
    this.initialText,
    this.initialImages,
    required this.onUpdate,
    this.onDelete,
  }) : super(key: key);

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _textEditingController = TextEditingController();
  List<File> _images = []; 

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.initialText ?? '';
    if (widget.initialImages != null) {
      _images.addAll(widget.initialImages!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
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
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    String entryText = _textEditingController.text;
    widget.onUpdate(entryText, _images);
    Navigator.pop(context, entryText);
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