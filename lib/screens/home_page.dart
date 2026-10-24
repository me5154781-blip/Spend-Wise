import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../services/store.dart';
import '../widgets/panel.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/txn_tile.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomePage({super.key, required this.onSeeAll});

  String get greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = store.inMonth(now);
    final inc = store.sum(month, expense: false);
    final out = store.sum(month, expense: true);
    final balance =
        store.sum(store.txns, expense: false) - store.sum(store.txns, expense: true);
    final used = store.monthlyBudget > 0 ? out / store.monthlyBudget : 0.0;
    final recent = store.txns.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(greeting, style: const TextStyle(color: kMuted, fontSize: 12)),
              Text(store.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
          ),
          const ProfileAvatar(radius: 22),
        ]),
        const SizedBox(height: 16),
        Panel(
          color: kOrange,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total balance',
                style: TextStyle(color: Colors.black87, fontSize: 12)),
            const SizedBox(height: 8),
            Text(money(balance),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('In: ${money(inc)}    Out: ${money(out)}',
                style: const TextStyle(color: Colors.black87, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Monthly budget',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(used * 100).toStringAsFixed(0)}% used',
                  style: const TextStyle(color: kMuted, fontSize: 11)),
            ]),
            const SizedBox(height: 10),
            Bar(used),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
              onTap: onSeeAll,
              child: const Text('See all',
                  style: TextStyle(color: kMuted, fontSize: 12))),
        ]),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
                child: Text('No transactions yet',
                    style: TextStyle(color: kMuted))),
          )
        else
          ...recent.map(TxnTile.new),
      ],
    );
  }
}
