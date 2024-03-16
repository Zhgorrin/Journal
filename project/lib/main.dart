import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'diary_entry_page.dart';

void main() {
  runApp(const MyApp());
}

class DiaryEntry {
  int id;
  String text;
  List<String> imagePaths;
  int moodIndex;
  DateTime dateTime;

  DiaryEntry({
    required this.id,
    required this.text,
    required this.imagePaths,
    required this.moodIndex,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imagePaths': imagePaths.join(','),
      'moodIndex': moodIndex,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  static DiaryEntry fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      text: map['text'],
      imagePaths: map['imagePaths'].split(','),
      moodIndex: map['moodIndex'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
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
            moodIndex INTEGER,
            dateTime INTEGER
          )
          ''');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ThemeData.dark().canvasColor,
        colorScheme: ColorScheme.dark(
          secondary: Colors.green[900]!,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DiaryEntry> diaryEntries = [];

  Map<int, String> moodEmojiMap = {
    0: '😢',
    1: '😞',
    2: '😐',
    3: '😊',
    4: '😄',
  };

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final Database database = await openMyDatabase();
    final List<Map<String, dynamic>> maps =
        await database.query('diary_entries');
    setState(() {
      diaryEntries = List.generate(maps.length, (i) {
        return DiaryEntry.fromMap(maps[i]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('My Diary')),
        backgroundColor: const Color.fromARGB(255, 31, 30, 30),
      ),
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
                color: Colors.green[900],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Mood:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        '${moodEmojiMap[entry.moodIndex]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 71,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Date: ${DateFormat.yMd().format(entry.dateTime)}\n'
                      'Time: ${DateFormat.jm().format(entry.dateTime)}',
                      style: const TextStyle(color: Colors.white),
                    ),
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
        backgroundColor: Colors.green[900],
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToDiaryEntryPage(
      BuildContext context, DiaryEntry? entry) async {
    if (entry != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryEntryPage(
            initialText: entry.text,
            initialImages: entry.imagePaths.map((path) => File(path)).toList(),
            initialMood: entry.moodIndex,
            onUpdate: (text, images, mood) {
              setState(() {
                entry.text = text;
                entry.imagePaths = images.map((image) => image.path).toList();
                entry.moodIndex = mood;
              });
              _saveEntryToDatabase(entry);
            },
            onDelete: () async {
              await _deleteEntry(entry);
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryEntryPage(
            initialMood: 2,
            onUpdate: (text, images, mood) {
              setState(() {
                diaryEntries.add(DiaryEntry(
                  id: diaryEntries.length + 1,
                  text: text,
                  imagePaths: images.map((image) => image.path).toList(),
                  moodIndex: mood,
                  dateTime: DateTime.now(),
                ));
              });
              _saveEntryToDatabase(null);
            },
          ),
        ),
      );
    }
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

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final Database database = await openMyDatabase();
    await database.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    setState(() {
      diaryEntries.remove(entry);
    });
  }
}
