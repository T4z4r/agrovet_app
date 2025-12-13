class Expense {
  final int id;
  final String category;
  final int amount; // Changed from double to int as per API spec
  final String? description; // Made optional as per API spec
  final String date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).round(),
      description: json['description'],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }
}
