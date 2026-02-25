class Transaction {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String?,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'category': category,
    };
  }
}
