import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'diary_entry_page.dart';

void main() {
  runApp(const MyApp());
}

class DiaryEntry {
  int id;
  String text;
  List<String> imagePaths;
  int moodIndex;

  DiaryEntry({
    required this.id,
    required this.text,
    required this.imagePaths,
    required this.moodIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imagePaths': imagePaths.join(','),
      'moodIndex': moodIndex,
    };
  }

  static DiaryEntry fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      text: map['text'],
      imagePaths: map['imagePaths'].split(','),
      moodIndex: map['moodIndex'],
    );
  }
}

Future<Database> openMyDatabase() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "my_database.db");
  return await openDatabase(path, version: 1,
      onCreate: (Database database, int version) async {
    await database.execute('''
          CREATE TABLE diary_entries(
            id INTEGER PRIMARY KEY,
            text TEXT,
            imagePaths TEXT,
            moodIndex INTEGER
          )
          ''');
  });
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
  List<DiaryEntry> diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final Database database = await openMyDatabase();
    final List<Map<String, dynamic>> maps = await database.query('diary_entries');
    setState(() {
      diaryEntries = List.generate(maps.length, (i) {
        return DiaryEntry.fromMap(maps[i]);
      });
    });
  }

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
              _navigateToDiaryEntryPage(context, entry);
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
                    entry.text,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Mood: ${entry.moodIndex}',
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
          await _navigateToDiaryEntryPage(context, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToDiaryEntryPage(BuildContext context, DiaryEntry? entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEntryPage(
          initialText: entry?.text,
          initialImages: entry?.imagePaths.map((path) => File(path)).toList() ?? [],
          initialMood: entry?.moodIndex ?? 2,
          onUpdate: (text, images, mood) {
            if (entry != null) {
              setState(() {
                entry.text = text;
                entry.imagePaths = images.map((image) => image.path).toList();
                entry.moodIndex = mood;
              });
            } else {
              setState(() {
                diaryEntries.add(DiaryEntry(
                  id: diaryEntries.length + 1,
                  text: text,
                  imagePaths: images.map((image) => image.path).toList(),
                  moodIndex: mood,
                ));
              });
            }
            _saveEntryToDatabase(entry);
          },
        ),
      ),
    );
  }

  Future<void> _saveEntryToDatabase(DiaryEntry? entry) async {
    final Database database = await openMyDatabase();
    if (entry != null) {
      await database.update(
        'diary_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } else {
      final newEntry = diaryEntries.last;
      await database.insert(
        'diary_entries',
        newEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}