import 'package:flutter/material.dart';

import 'app.dart';
import 'services/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const ExpenseApp());
}
