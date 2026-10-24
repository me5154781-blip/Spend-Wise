import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../services/store.dart';

class CategoriesSheet extends StatelessWidget {
  const CategoriesSheet({super.key});

  Future<void> _edit(BuildContext context, {String? name}) async {
    final n = TextEditingController(text: name ?? '');
    final b = TextEditingController(
        text: name == null || store.categories[name] == 0
            ? ''
            : store.categories[name]!.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: Text(name == null ? 'New category' : 'Edit $name'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (name == null)
            TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: b,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly budget', prefixText: 'Rs ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && (name != null || n.text.trim().isNotEmpty)) {
      store.setCategory(name ?? n.text.trim(), double.tryParse(b.text) ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Manage categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...store.categories.entries.map((c) => ListTile(
                title: Text(c.key),
                subtitle: Text(c.value == 0 ? 'No limit' : money(c.value),
                    style: const TextStyle(color: kMuted)),
                onTap: () => _edit(context, name: c.key),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: kRed),
                    onPressed: () => store.removeCategory(c.key)),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: kOrange, foregroundColor: Colors.black),
              onPressed: () => _edit(context),
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            ),
          ),
        ]),
      ),
    );
  }
}
