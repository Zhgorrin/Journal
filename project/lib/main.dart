import 'dart:io';
import 'package:flutter/material.dart';
import 'diary_entry_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> diaryEntries = [];
  List<List<File>> diaryImages = [];
  List<int> moodIndices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Diary')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: diaryEntries.length,
        itemBuilder: (context, index) {
          final entry = diaryEntries[index];
          final moodIndex = moodIndices[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEntryPage(
                    initialText: entry,
                    initialImages: diaryImages[index],
                    initialMood: moodIndex,
                    onUpdate: (text, images, mood) {
                      setState(() {
                        diaryEntries[index] = text;
                        diaryImages[index] = images;
                        moodIndices[index] = mood;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        diaryEntries.removeAt(index);
                        diaryImages.removeAt(index);
                        moodIndices.removeAt(index);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Mood: $moodIndex',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryEntryPage(
                onUpdate: (text, images, mood) {
                  setState(() {
                    diaryEntries.add(text);
                    diaryImages.add(images);
                    moodIndices.add(mood);
                  });
                },
                initialMood: 2,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
