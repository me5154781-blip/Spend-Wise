import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../services/store.dart';
import '../widgets/panel.dart';
import '../widgets/pill_chip.dart';
import '../widgets/txn_sheet.dart';
import '../widgets/txn_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  String filter = 'All'; // All / Expense / Income / <category>

  void shift(int d) =>
      setState(() => month = DateTime(month.year, month.month + d));

  @override
  Widget build(BuildContext context) {
    var list = store.inMonth(month);
    if (filter == 'Expense') list = list.where((t) => t.isExpense).toList();
    if (filter == 'Income') list = list.where((t) => !t.isExpense).toList();
    if (!['All', 'Expense', 'Income'].contains(filter)) {
      list = list.where((t) => t.category == filter).toList();
    }
    final chips = ['All', 'Expense', 'Income', ...store.categories.keys];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text('History',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                onPressed: () => shift(-1), icon: const Icon(Icons.chevron_left)),
            Text('${kMonths[month.month - 1]} ${month.year}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: () => shift(1), icon: const Icon(Icons.chevron_right)),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: chips
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PillChip(
                          label: c,
                          selected: filter == c,
                          onTap: () => setState(() => filter = c)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Column(children: [
              Text('No transactions yet', style: TextStyle(color: kMuted)),
              SizedBox(height: 8),
              Text('Tap to edit · swipe left to delete',
                  style: TextStyle(color: kMuted, fontSize: 11)),
            ]),
          )
        else
          ...list.map((t) => Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                      color: kRed.withOpacity(.3),
                      borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.delete, color: kRed),
                ),
                onDismissed: (_) => store.remove(t.id),
                child: GestureDetector(
                    onTap: () => showTxnSheet(context, existing: t),
                    child: TxnTile(t)),
              )),
      ],
    );
  }
}
