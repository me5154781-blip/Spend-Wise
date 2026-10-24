import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/txn.dart';
import '../services/store.dart';
import 'pill_chip.dart';

void showTxnSheet(BuildContext context, {Txn? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kCard,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => TxnSheet(existing: existing),
  );
}

class TxnSheet extends StatefulWidget {
  final Txn? existing;
  const TxnSheet({super.key, this.existing});
  @override
  State<TxnSheet> createState() => _TxnSheetState();
}

class _TxnSheetState extends State<TxnSheet> {
  late bool isExpense = widget.existing?.isExpense ?? true;
  late String? category = widget.existing?.category;
  late DateTime date = widget.existing?.date ?? DateTime.now();
  late final amount = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.amount.toStringAsFixed(0));
  late final title = TextEditingController(text: widget.existing?.title ?? '');

  void save() {
    final a = double.tryParse(amount.text);
    if (a == null || a <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    final cat = category ??
        (store.categories.isNotEmpty ? store.categories.keys.first : 'Other');
    store.upsert(Txn(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.text.trim().isEmpty ? cat : title.text.trim(),
      amount: a,
      isExpense: isExpense,
      category: cat,
      date: date,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = store.categories.keys.toList();
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.existing == null ? 'Add transaction' : 'Edit transaction',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            SizedBox(
                height: 36,
                child: PillChip(
                    label: 'Expense',
                    selected: isExpense,
                    onTap: () => setState(() => isExpense = true))),
            const SizedBox(width: 8),
            SizedBox(
                height: 36,
                child: PillChip(
                    label: 'Income',
                    selected: !isExpense,
                    onTap: () => setState(() => isExpense = false))),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            autofocus: widget.existing == null,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(prefixText: 'Rs ', hintText: '0'),
          ),
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Note / title')),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cats
                .map((c) => SizedBox(
                      height: 34,
                      child: PillChip(
                          label: c,
                          selected: (category ?? cats.first) == c,
                          onTap: () => setState(() => category = c)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100));
              if (d != null) setState(() => date = d);
            },
            icon: const Icon(Icons.calendar_today, size: 16, color: kOrange),
            label: Text('${date.day}/${date.month}/${date.year}',
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
