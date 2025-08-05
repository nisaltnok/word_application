// screens/word_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_word_app_1/helper/services/word_service.dart';
import 'package:flutter_word_app_1/models/word.dart';
import 'package:flutter_word_app_1/screens/add_word_form..dart';
//import 'package:flutter_word_app_1/services/word_service.dart';
//import 'add_word_form.dart'; // Form import et

class WordListScreen extends StatefulWidget {
  WordListScreen({Key? key}) : super(key: key);

  @override
  WordListScreenState createState() => WordListScreenState(); // Public yaptık
}

class WordListScreenState extends State<WordListScreen> { // Public State sınıfı
  final WordService _wordService = WordService();
  List<Word> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWords(); // Güncellendi
  }

  // Public method - dışarıdan erişelebilir
  Future<void> loadWords() async {
    try {
      await _wordService.init();
      List<Word> words = await _wordService.getAllWords();
      setState(() {
        _words = words;
        _isLoading = false;
      });
    } catch (e) {
      print("Kelimeler yüklenirken hata: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleWord() async {
    // Artık sample word yerine dialog açacağız
    _showAddWordDialog();
  }

  void _showAddWordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: AddWordForm(
              onWordAdded: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                loadWords(); // Listeyi yenile - Güncellendi
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteWord(int id) async {
    try {
      await _wordService.deleteWord(id);
      loadWords(); // Listeyi yenile - Güncellendi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kelime silindi')),
      );
    } catch (e) {
      print("Kelime silinirken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _words.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz kelime eklenmemiş',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddWordDialog(),
                        child: Text('Kelime Ekle'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    Word word = _words[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          word.englishWord,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.turkishWord,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              word.wordType,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (word.story != null && word.story!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  word.story!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(word),
                        ),
                        onTap: () {
                          // Kelime detayına git veya düzenleme sayfasına yönlendir
                          _showWordDetails(word);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteDialog(Word word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kelime Sil'),
          content: Text('${word.englishWord} kelimesini silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteWord(word.id!);
              },
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showWordDetails(Word word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(word.englishWord),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Türkçe: ${word.turkishWord}'),
              SizedBox(height: 8),
              Text('Tür: ${word.wordType}'),
              if (word.story != null && word.story!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Hikaye:'),
                SizedBox(height: 4),
                Text(word.story!, style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}