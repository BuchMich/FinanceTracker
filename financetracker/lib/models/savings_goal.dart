class SavingsGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;

  const SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  int get progressPercent => (progress * 100).round();

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as int?,
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
    };
  }
}
