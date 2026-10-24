import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/store.dart';
import '../widgets/txn_sheet.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'stats_page.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: index, children: [
            HomePage(onSeeAll: () => setState(() => index = 1)),
            const HistoryPage(),
            const StatsPage(),
            const ProfilePage(),
          ]),
        ),
        floatingActionButton: index <= 1
            ? FloatingActionButton(
                backgroundColor: kOrange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                onPressed: () => showTxnSheet(context),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: kCard, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: List.generate(4, (i) {
                  const labels = ['Home', 'History', 'Stats', 'Profile'];
                  final sel = i == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => index = i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? kOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                     child: Text(labels[i],
    textAlign: TextAlign.center,
    style: TextStyle(
                      
                                fontSize: 12,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                                color: sel ? Colors.black : kMuted)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
