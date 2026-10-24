import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../services/store.dart';
import '../widgets/categories_sheet.dart';
import '../widgets/panel.dart';
import '../widgets/profile_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(String t, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: onTap,
            child: Panel(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(t),
                const Icon(Icons.chevron_right, size: 18, color: kMuted),
              ]),
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: [
        const Center(child: ProfileAvatar(radius: 42)),
        const SizedBox(height: 14),
        Center(
            child: Text(store.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 4),
        Center(
            child: Text(store.email,
                style: const TextStyle(color: kMuted, fontSize: 12))),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Monthly budget',
                  style: TextStyle(color: kMuted, fontSize: 11)),
              const SizedBox(height: 8),
              Text(
                  money(store.monthlyBudget),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total transactions',
                  style: TextStyle(color: kMuted, fontSize: 11)),
              const SizedBox(height: 8),
              Text('${store.txns.length}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ])),
          ),
        ]),
        const SizedBox(height: 14),
        row('Edit profile', () => _editProfile(context)),
        row('Manage categories', () => _manageCategories(context)),
        row('Monthly budget', () => _editBudget(context)),
        row('Export data', () async {
          await Clipboard.setData(ClipboardData(text: store.csv()));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('CSV copied to clipboard')));
          }
        }),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _confirmLogout(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kRed.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kRed.withOpacity(.4)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: kRed, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final n = TextEditingController(text: store.name);
    final e = TextEditingController(text: store.email);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Edit profile'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: e, decoration: const InputDecoration(labelText: 'Email')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) store.setProfile(n.text.trim(), e.text.trim());
  }

  Future<void> _editBudget(BuildContext context) async {
    final c = TextEditingController(
        text: store.monthlyBudget == 0 ? '' : store.monthlyBudget.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Monthly budget'),
        content: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'Rs ')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) store.setBudget(double.tryParse(c.text) ?? 0);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Logout'),
        content: const Text('You will be signed out. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (ok == true) store.logout();
  }

  void _manageCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const CategoriesSheet(),
    );
  }
}
