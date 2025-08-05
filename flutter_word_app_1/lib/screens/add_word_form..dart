// screens/add_word_form.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_word_app_1/helper/services/word_service.dart';
import 'package:flutter_word_app_1/models/word.dart';
//import 'package:flutter_word_app_1/services/word_service.dart';
import 'package:image_picker/image_picker.dart';

class AddWordForm extends StatefulWidget {
  final VoidCallback? onWordAdded; // Kelime eklendiğinde listeyi yenilemek için

  AddWordForm({this.onWordAdded});

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends State<AddWordForm> {
  final _formKey = GlobalKey<FormState>();
  final WordService _wordService = WordService();
  
  // Form controllers
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _turkishController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  
  // Resim için değişkenler
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  String _selectedWordType = 'Noun'; // Varsayılan değer
  bool _isLoading = false;

  // Kelime türleri
  final List<String> _wordTypes = [
    'Noun',        // İsim
    'Verb',        // Fiil
    'Adjective',   // Sıfat
    'Adverb',      // Zarf
    'Preposition', // Edat
    'Pronoun',     // Zamir
    'Other'        // Diğer
  ];

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _addWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Word newWord = Word(
        englishWord: _englishController.text.trim(),
        turkishWord: _turkishController.text.trim(),
        wordType: _selectedWordType,
        story: _storyController.text.trim().isEmpty 
            ? null 
            : _storyController.text.trim(),
      );

      await _wordService.init();
      int id = await _wordService.addWord(newWord);
      
      print("Kelime eklendi, ID: $id");
      
      // Form temizle
      _clearForm();
      
      // Callback çağır (listeyi yenile)
      if (widget.onWordAdded != null) {
        widget.onWordAdded!();
      }
      
      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kelime başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print("Kelime eklenirken hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: Kelime eklenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _englishController.clear();
    _turkishController.clear();
    _storyController.clear();
    setState(() {
      _selectedWordType = 'Noun';
      _imageFile = null; // Resmi de temizle
    });
  }

  Future<void> _resimSec() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Text(
              'Yeni Kelime Ekle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            
            // Resim Ekleme Bölümü
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.image, color: Colors.blue),
                    title: Text('Resim Ekle'),
                    subtitle: _imageFile != null 
                        ? Text('Resim seçildi ✓', style: TextStyle(color: Colors.green))
                        : Text('Kelime için resim seçin (Opsiyonel)'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _resimSec,
                  ),
                  if (_imageFile != null) ...[
                    Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: _resimSec,
                                icon: Icon(Icons.refresh, size: 16),
                                label: Text('Değiştir'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _imageFile = null;
                                  });
                                },
                                icon: Icon(Icons.delete, size: 16, color: Colors.red),
                                label: Text('Kaldır', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // İngilizce Kelime
            TextFormField(
              controller: _englishController,
              decoration: InputDecoration(
                labelText: 'İngilizce Kelime *',
                hintText: 'Örn: beautiful',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'İngilizce kelime boş bırakılamaz';
                }
                if (value.trim().length < 2) {
                  return 'En az 2 karakter olmalı';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Türkçe Anlamı
            TextFormField(
              controller: _turkishController,
              decoration: InputDecoration(
                labelText: 'Türkçe Anlamı *',
                hintText: 'Örn: güzel',
                prefixIcon: Icon(Icons.translate),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Türkçe anlamı boş bırakılamaz';
                }
                if (value.trim().length < 2) {
                  return 'En az 2 karakter olmalı';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Kelime Türü
            DropdownButtonFormField<String>(
              value: _selectedWordType,
              decoration: InputDecoration(
                labelText: 'Kelime Türü *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _wordTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(_getWordTypeInTurkish(type)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWordType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Hikaye (Opsiyonel)
            TextFormField(
              controller: _storyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Hikaye (Opsiyonel)',
                hintText: 'Bu kelimeyi nerede/nasıl öğrendiniz?',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _clearForm,
                    child: Text('Temizle'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addWord,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Kelime Ekle',
                            style: TextStyle(fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWordTypeInTurkish(String englishType) {
    switch (englishType) {
      case 'Noun':
        return 'İsim';
      case 'Verb':
        return 'Fiil';
      case 'Adjective':
        return 'Sıfat';
      case 'Adverb':
        return 'Zarf';
      case 'Preposition':
        return 'Edat';
      case 'Pronoun':
        return 'Zamir';
      case 'Other':
        return 'Diğer';
      default:
        return englishType;
    }
  }
}