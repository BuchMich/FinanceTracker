class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  const Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

final List<Transaction> demoTransactions = [
  Transaction(
    title: 'Supermarkt',
    amount: -54.30,
    date: DateTime(2026, 1, 30),
    category: 'Essen',
  ),
  Transaction(
    title: 'Gehalt',
    amount: 2100.00,
    date: DateTime(2026, 1, 28),
    category: 'Einkommen',
  ),
  Transaction(
    title: 'Miete',
    amount: -750.00,
    date: DateTime(2026, 2, 1),
    category: 'Wohnen',
  ),
  Transaction(
    title: 'Streaming',
    amount: -14.99,
    date: DateTime(2026, 1, 25),
    category: 'Freizeit',
  ),
  Transaction(
    title: 'Freelance',
    amount: 450.00,
    date: DateTime(2026, 1, 20),
    category: 'Einkommen',
  ),
];
