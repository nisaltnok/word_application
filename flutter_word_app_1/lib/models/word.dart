class Word {
  final int? id; // SQFLite için nullable id
  final String englishWord;
  final String turkishWord;
  final String wordType;
  final String? story;
  final String? imageBytes; // SQFLite'da String (Base64) olarak saklayacağız
  final bool isLearned;
  final String? createdAt;

  Word({
    this.id,
    required this.englishWord,
    required this.turkishWord,
    required this.wordType,
    this.story,
    this.imageBytes,
    this.isLearned = false,
    this.createdAt,
  });

  // Map'ten Word objesi oluştur (SQFLite'dan veri okurken) - EKSİK OLAN METOD
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      englishWord: map['english_word'] as String,
      turkishWord: map['turkish_word'] as String,
      wordType: map['word_type'] as String,
      story: map['story'] as String?,
      imageBytes: map['image_bytes'] as String?,
      isLearned: (map['is_learned'] as int) == 1, // SQLite'da boolean 0/1 olur
      createdAt: map['created_at'] as String?,
    );
  }

  // Word objesini Map'e çevir (SQFLite'a veri yazarken) - EKSİK OLAN METOD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english_word': englishWord,
      'turkish_word': turkishWord,
      'word_type': wordType,
      'story': story,
      'image_bytes': imageBytes,
      'is_learned': isLearned ? 1 : 0, // boolean'ı int'e çeviriyoruz
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  // Copy with metodu (güncellemeler için)
  Word copyWith({
    int? id,
    String? englishWord,
    String? turkishWord,
    String? wordType,
    String? story,
    String? imageBytes,
    bool? isLearned,
    String? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      englishWord: englishWord ?? this.englishWord,
      turkishWord: turkishWord ?? this.turkishWord,
      wordType: wordType ?? this.wordType,
      story: story ?? this.story,
      imageBytes: imageBytes ?? this.imageBytes,
      isLearned: isLearned ?? this.isLearned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Word{id: $id, englishWord: $englishWord, turkishWord: $turkishWord, wordType: $wordType, isLearned: $isLearned}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word &&
        other.id == id &&
        other.englishWord == englishWord &&
        other.turkishWord == turkishWord &&
        other.wordType == wordType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        englishWord.hashCode ^
        turkishWord.hashCode ^
        wordType.hashCode;
  }
}