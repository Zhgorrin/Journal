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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEntryPage(
                    initialText: entry,
                    initialImages: diaryImages[index], 
                    onUpdate: (text, images) {
                      setState(() {
                        diaryEntries[index] = text;
                        diaryImages[index] = images; 
                      });
                    },
                    onDelete: () {
                      setState(() {
                        diaryEntries.removeAt(index);
                        diaryImages.removeAt(index); 
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
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEntry = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryEntryPage(
                onUpdate: (text, images) {
                  setState(() {
                    diaryEntries.add(text);
                    diaryImages.add(images); 
                  });
                },
              ),
            ),
          );
          if (newEntry != null) {
            setState(() {
              diaryEntries.add(newEntry);
              diaryImages.add([]); 
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}