class Txn {
  final String id;
  String title;
  double amount;
  bool isExpense;
  String category;
  DateTime date;

  Txn({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isExpense': isExpense,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Txn.fromJson(Map<String, dynamic> j) => Txn(
        id: j['id'],
        title: j['title'],
        amount: (j['amount'] as num).toDouble(),
        isExpense: j['isExpense'],
        category: j['category'],
        date: DateTime.parse(j['date']),
      );
}
