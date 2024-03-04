import 'package:flutter/material.dart';

class DiaryEntryPage extends StatefulWidget {
  final String? initialText;
  final Function(String) onUpdate;
  final VoidCallback? onDelete;

  const DiaryEntryPage({
    super.key,
    this.initialText,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.initialText ?? '';
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
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    String entryText = _textEditingController.text;
    widget.onUpdate(entryText);
    Navigator.pop(context, entryText);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
