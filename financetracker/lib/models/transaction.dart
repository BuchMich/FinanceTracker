class Transaction {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' oder 'expense'
  final DateTime date;
  final String category;

  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  /// Gibt den Betrag mit Vorzeichen zurück (negativ für Ausgaben)
  double get signedAmount => isExpense ? -amount : amount;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String().split('T').first,
      'category': category,
    };
  }
}
