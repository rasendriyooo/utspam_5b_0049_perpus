class BorrowTransaction {
  final int? id;
  final int userId;
  final int bookId;
  final String borrowerName;
  final int durationDays;
  final DateTime startDate;
  final double totalCost;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? bookTitle;
  final String? bookCoverUrl;
  final String? bookGenre;
  final String? bookAuthor;
  final double? bookPricePerDay;

  BorrowTransaction({
    this.id,
    required this.userId,
    required this.bookId,
    required this.borrowerName,
    required this.durationDays,
    required this.startDate,
    required this.totalCost,
    this.status = 'aktif',
    DateTime? createdAt,
    this.updatedAt,
    this.bookTitle,
    this.bookCoverUrl,
    this.bookGenre,
    this.bookAuthor,
    this.bookPricePerDay,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'borrower_name': borrowerName,
      'duration_days': durationDays,
      'start_date': startDate.toIso8601String(),
      'total_cost': totalCost,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BorrowTransaction.fromMap(Map<String, dynamic> map) {
    return BorrowTransaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      bookId: map['book_id'] as int,
      borrowerName: map['borrower_name'] as String,
      durationDays: map['duration_days'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      totalCost: (map['total_cost'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      bookTitle: map['book_title'] as String?,
      bookCoverUrl: map['book_cover_url'] as String?,
      bookGenre: map['book_genre'] as String?,
      bookAuthor: map['book_author'] as String?,
      bookPricePerDay: map['book_price_per_day'] != null
          ? (map['book_price_per_day'] as num).toDouble()
          : null,
    );
  }

  BorrowTransaction copyWith({
    int? id,
    int? userId,
    int? bookId,
    String? borrowerName,
    int? durationDays,
    DateTime? startDate,
    double? totalCost,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookTitle,
    String? bookCoverUrl,
    String? bookGenre,
    String? bookAuthor,
    double? bookPricePerDay,
  }) {
    return BorrowTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      borrowerName: borrowerName ?? this.borrowerName,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookTitle: bookTitle ?? this.bookTitle,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      bookGenre: bookGenre ?? this.bookGenre,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookPricePerDay: bookPricePerDay ?? this.bookPricePerDay,
    );
  }
}
