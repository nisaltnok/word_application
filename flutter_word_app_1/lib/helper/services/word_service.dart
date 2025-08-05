import 'package:flutter_word_app_1/models/word.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
//import '../models/word.dart';

class WordService {
  static Database? _database;
  
  // Singleton pattern (isteğe bağlı)
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    await init();
    return _database!;
  }

  // Initialize database - Isar'daki init() metodunun karşılığı
  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, 'kelime_app.db');
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
      
      debugPrint("SQFLite database başlatıldı: ${directory.path}");
      debugPrint("Database path: $path");
      
    } catch (e) {
      debugPrint("Database başlatma hatası: $e");
      rethrow; // Hatayı yukarı fırlat
    }
  }

  // Tabloları oluştur
  Future<void> _createTables(Database db, int version) async {
    try {
      // Words tablosu
      await db.execute('''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          english_word TEXT NOT NULL,
          turkish_word TEXT NOT NULL,
          word_type TEXT NOT NULL,
          story TEXT,
          image_bytes TEXT,
          is_learned INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Word types tablosu
      await db.execute('''
        CREATE TABLE word_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type_name TEXT NOT NULL UNIQUE,
          description TEXT
        )
      ''');

      // Varsayılan kelime tiplerini ekle
      await _insertDefaultWordTypes(db);
      
      debugPrint("Tablolar başarıyla oluşturuldu");
      
    } catch (e) {
      debugPrint("Tablo oluşturma hatası: $e");
      rethrow;
    }
  }

  // Database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Database upgrade: $oldVersion -> $newVersion");
    // Gelecekte schema değişiklikleri burada yapılacak
  }

  // Varsayılan kelime tiplerini ekle
  Future<void> _insertDefaultWordTypes(Database db) async {
    List<Map<String, dynamic>> defaultTypes = [
      {'type_name': 'Noun', 'description': 'İsim'},
      {'type_name': 'Verb', 'description': 'Fiil'},
      {'type_name': 'Adjective', 'description': 'Sıfat'},
      {'type_name': 'Adverb', 'description': 'Zarf'},
      {'type_name': 'Pronoun', 'description': 'Zamir'},
      {'type_name': 'Preposition', 'description': 'Edat'},
      {'type_name': 'Conjunction', 'description': 'Bağlaç'},
      {'type_name': 'Interjection', 'description': 'Ünlem'},
    ];

    for (var type in defaultTypes) {
      await db.insert('word_types', type, 
        conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // CRUD İşlemleri

  // Kelime ekle
  Future<int> addWord(Word word) async {
    try {
      final db = await database;
      int id = await db.insert('words', word.toMap());
      debugPrint("Kelime eklendi: ${word.englishWord} (ID: $id)");
      return id;
    } catch (e) {
      debugPrint("Kelime ekleme hatası: $e");
      rethrow;
    }
  }

  // Tüm kelimeleri getir
  Future<List<Word>> getAllWords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('words');
      
      List<Word> words = List.generate(maps.length, (i) {
        return Word.fromMap(maps[i]);
      });
      
      debugPrint("${words.length} kelime getirildi");
      return words;
      
    } catch (e) {
      debugPrint("Kelime getirme hatası: $e");
      return [];
    }
  }

  // ID ile kelime getir
  Future<Word?> getWordById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Word.fromMap(maps.first);
      }
      return null;
      
    } catch (e) {
      debugPrint("Kelime getirme hatası (ID: $id): $e");
      return null;
    }
  }

  // Kelime tipine göre getir
  Future<List<Word>> getWordsByType(String wordType) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        where: 'word_type = ?',
        whereArgs: [wordType],
      );

      return List.generate(maps.length, (i) {
        return Word.fromMap(maps[i]);
      });
      
    } catch (e) {
      debugPrint("Kelime tipine göre getirme hatası: $e");
      return [];
    }
  }

  // Kelime ara
  Future<List<Word>> searchWords(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        where: 'english_word LIKE ? OR turkish_word LIKE ? OR story LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );

      return List.generate(maps.length, (i) {
        return Word.fromMap(maps[i]);
      });
      
    } catch (e) {
      debugPrint("Kelime arama hatası: $e");
      return [];
    }
  }

  // Kelime güncelle
  Future<bool> updateWord(Word word) async {
    try {
      final db = await database;
      int count = await db.update(
        'words',
        word.toMap(),
        where: 'id = ?',
        whereArgs: [word.id],
      );
      
      debugPrint("Kelime güncellendi: ${word.englishWord}");
      return count > 0;
      
    } catch (e) {
      debugPrint("Kelime güncelleme hatası: $e");
      return false;
    }
  }

  // Kelime sil
  Future<bool> deleteWord(int id) async {
    try {
      final db = await database;
      int count = await db.delete(
        'words',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      debugPrint("Kelime silindi (ID: $id)");
      return count > 0;
      
    } catch (e) {
      debugPrint("Kelime silme hatası: $e");
      return false;
    }
  }

  // Öğrenilen kelimeleri getir
  Future<List<Word>> getLearnedWords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        where: 'is_learned = ?',
        whereArgs: [1],
      );

      return List.generate(maps.length, (i) {
        return Word.fromMap(maps[i]);
      });
      
    } catch (e) {
      debugPrint("Öğrenilen kelimeler getirme hatası: $e");
      return [];
    }
  }

  // Rastgele kelimeler getir
  Future<List<Word>> getRandomWords(int count) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        orderBy: 'RANDOM()',
        limit: count,
      );

      return List.generate(maps.length, (i) {
        return Word.fromMap(maps[i]);
      });
      
    } catch (e) {
      debugPrint("Rastgele kelimeler getirme hatası: $e");
      return [];
    }
  }

  // İstatistikler
  Future<int> getTotalWordCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM words');
      return result.first['count'] as int;
    } catch (e) {
      debugPrint("Toplam kelime sayısı hatası: $e");
      return 0;
    }
  }

  Future<int> getLearnedWordCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM words WHERE is_learned = 1');
      return result.first['count'] as int;
    } catch (e) {
      debugPrint("Öğrenilen kelime sayısı hatası: $e");
      return 0;
    }
  }

  // Database'i kapat
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint("Database kapatıldı");
    }
  }

  // Database'i sıfırla (test için)
  Future<void> resetDatabase() async {
    try {
      await close();
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, 'kelime_app.db');
      final file = File(path);
      
      if (await file.exists()) {
        await file.delete();
        debugPrint("Database dosyası silindi");
      }
      
      await init(); // Yeniden başlat
    } catch (e) {
      debugPrint("Database sıfırlama hatası: $e");
    }
  }
}