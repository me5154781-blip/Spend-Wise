import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/txn.dart';
import 'panel.dart';

class TxnTile extends StatelessWidget {
  final Txn t;
  const TxnTile(this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: (t.isExpense ? kRed : kGreen).withOpacity(.15),
            child: Icon(
                t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: t.isExpense ? kRed : kGreen,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                  '${t.category} · ${t.date.day} ${kMonths[t.date.month - 1].substring(0, 3)}',
                  style: const TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ),
          Text('${t.isExpense ? '-' : '+'}${money(t.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: t.isExpense ? kRed : kGreen)),
        ]),
      ),
    );
  }
}
