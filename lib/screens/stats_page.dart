import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/txn.dart';
import '../services/store.dart';
import '../widgets/panel.dart';
import '../widgets/pill_chip.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String range = 'Month';

  List<Txn> get filtered {
    final now = DateTime.now();
    return store.txns.where((t) {
      switch (range) {
        case 'Week':
          return now.difference(t.date).inDays < 7 && !t.date.isAfter(now);
        case 'Year':
          return t.date.year == now.year;
        default:
          return t.date.year == now.year && t.date.month == now.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = filtered.where((t) => t.isExpense).toList();
    final byCat = <String, double>{};
    for (final t in expenses) {
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
    }
    final total = byCat.values.fold(0.0, (a, b) => a + b);
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // spent this month per category (for category budgets)
    final monthExp = store.inMonth(DateTime.now()).where((t) => t.isExpense);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text('Statistics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(
            children: ['Month', 'Week', 'Year']
                .map((r) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 36,
                        child: PillChip(
                            label: r,
                            selected: range == r,
                            onTap: () => setState(() => range = r)),
                      ),
                    ))
                .toList()),
        const SizedBox(height: 16),
        Panel(
          child: Row(children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: DonutPainter(entries.map((e) => e.value).toList(), total),
                child: Center(
                    child: Text(total == 0 ? '' : money(total),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: entries.isEmpty
                  ? const Row(children: [
                      Icon(Icons.square, size: 12, color: Colors.white70),
                      SizedBox(width: 6),
                      Text('No data', style: TextStyle(fontSize: 12)),
                    ])
                  : Column(
                      children: List.generate(entries.length, (i) {
                      final e = entries[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          Icon(Icons.square,
                              size: 12,
                              color: kChartColors[i % kChartColors.length]),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(e.key,
                                  style: const TextStyle(fontSize: 12))),
                          Text('${(e.value / total * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted)),
                        ]),
                      );
                    })),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('Category budgets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            children: store.categories.entries.map((c) {
              final spent = monthExp
                  .where((t) => t.category == c.key)
                  .fold(0.0, (a, b) => a + b.amount);
              final ratio = c.value > 0 ? spent / c.value : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(c.key,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_k(spent)} / ${_k(c.value)}',
                        style: const TextStyle(color: kMuted, fontSize: 12)),
                  ]),
                  const SizedBox(height: 8),
                  Bar(ratio),
                ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _k(double v) => 'Rs ${(v / 1000).toStringAsFixed(v >= 1000 ? 1 : 0)}k';
}

class DonutPainter extends CustomPainter {
  final List<double> values;
  final double total;
  DonutPainter(this.values, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      p.color = const Color(0xFFDDDDD5);
      canvas.drawArc(r, 0, math.pi * 2, false, p);
      return;
    }
    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      p.color = kChartColors[i % kChartColors.length];
      canvas.drawArc(r, start, math.max(sweep - 0.03, 0.01), false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) =>
      old.values != values || old.total != total;
}
