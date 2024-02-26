import 'package:memory/memory_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WordDB {
  static final WordDB instance = WordDB._init();

  static Database? _database;

  WordDB._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('word.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memory_word (
        wordSeq INTEGER PRIMARY KEY NOT NULL,
        chapter INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      if (oldVersion == 1) {
        await db.execute('''
          ALTER TABLE memory_word
          ADD COLUMN chapter INTEGER NOT NULL,
        ''');
      }
    }
  }

  Future<int> insertWord(WordModel wordModel) async {
    final db = await instance.database;

    final maps = await db.query(
      'memory_word',
      where: "wordSeq = '${wordModel.wordSeq}'",
    );

    if (maps.isNotEmpty) {
      return -1;
    } else {
      return await db.insert('memory_word', wordModel.toJson());
    }
  }

  Future<List<int>> selectWordSeq() async {
    final db = await instance.database;

    final maps = await db.query(
      'memory_word',
    );

    List<int> list = [];

    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        list.add(WordModel.fromJson(maps[i]).wordSeq);
      }
      return list;
    } else {
      return [];
    }
  }

  Future<List<WordModel>> selectWord() async {
    final db = await instance.database;

    final maps = await db.query(
      'memory_word',
    );

    List<WordModel> list = [];

    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        list.add(WordModel.fromJson(maps[i]));
      }
      return list;
    } else {
      return [];
    }
  }

  Future<int> deleteWord(int wordSeq) async {
    final db = await instance.database;

    return await db.delete(
      'memory_word',
      where: 'wordSeq = $wordSeq',
    );
  }
}
