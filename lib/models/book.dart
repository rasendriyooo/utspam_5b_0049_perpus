class Book {
  final int? id;
  final String title;
  final String genre;
  final double pricePerDay;
  final String coverUrl;
  final String synopsis;
  final String author;
  final int publishYear;

  Book({
    this.id,
    required this.title,
    required this.genre,
    required this.pricePerDay,
    required this.coverUrl,
    required this.synopsis,
    required this.author,
    required this.publishYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'price_per_day': pricePerDay,
      'cover_url': coverUrl,
      'synopsis': synopsis,
      'author': author,
      'publish_year': publishYear,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      genre: map['genre'] as String,
      pricePerDay: (map['price_per_day'] as num).toDouble(),
      coverUrl: map['cover_url'] as String,
      synopsis: map['synopsis'] as String,
      author: map['author'] as String,
      publishYear: map['publish_year'] as int,
    );
  }

  Book copyWith({
    int? id,
    String? title,
    String? genre,
    double? pricePerDay,
    String? coverUrl,
    String? synopsis,
    String? author,
    int? publishYear,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      coverUrl: coverUrl ?? this.coverUrl,
      synopsis: synopsis ?? this.synopsis,
      author: author ?? this.author,
      publishYear: publishYear ?? this.publishYear,
    );
  }
}
