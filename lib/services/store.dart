import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/txn.dart';

class Store extends ChangeNotifier {
  SharedPreferences? _p;
  String name = '';
  String email = '';
  String password = ''; // ⚠️ demo فقط: متخزن محليًا بدون تشفير
  bool loggedIn = false;
  bool get hasAccount => password.isNotEmpty;
  double monthlyBudget = 0;
  List<Txn> txns = [];
  // category -> monthly budget (0 = no limit)
  Map<String, double> categories = {'Food': 0, 'Transport': 0, 'Bills': 0};

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p!.getString('data');
    if (raw == null) return;
    final j = jsonDecode(raw);
    name = j['name'];
    email = j['email'];
    password = j['password'] ?? '';
    loggedIn = j['loggedIn'] ?? false;
    monthlyBudget = (j['budget'] as num).toDouble();
    txns = (j['txns'] as List).map((e) => Txn.fromJson(e)).toList();
    categories = (j['cats'] as Map)
        .map((k, v) => MapEntry(k as String, (v as num).toDouble()));
  }

  void _save() {
    _p?.setString(
        'data',
        jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'loggedIn': loggedIn,
          'budget': monthlyBudget,
          'txns': txns.map((e) => e.toJson()).toList(),
          'cats': categories,
        }));
    notifyListeners();
  }

  void upsert(Txn t) {
    final i = txns.indexWhere((e) => e.id == t.id);
    if (i >= 0) {
      txns[i] = t;
    } else {
      txns.add(t);
    }
    txns.sort((a, b) => b.date.compareTo(a.date));
    _save();
  }

  void remove(String id) {
    txns.removeWhere((e) => e.id == id);
    _save();
  }

  void register(String n, String e, String pass) {
    // حساب جديد = بيانات جديدة
    txns = [];
    monthlyBudget = 0;
    categories = {'Food': 0, 'Transport': 0, 'Bills': 0};
    name = n;
    email = e;
    password = pass;
    loggedIn = true;
    _save();
  }

  bool login(String e, String pass) {
    if (e.trim().toLowerCase() == email.toLowerCase() && pass == password) {
      loggedIn = true;
      _save();
      return true;
    }
    return false;
  }

  void logout() {
    loggedIn = false;
    _save();
  }

  void setProfile(String n, String e) {
    name = n;
    email = e;
    _save();
  }

  void setBudget(double v) {
    monthlyBudget = v;
    _save();
  }

  void setCategory(String c, double budget) {
    categories[c] = budget;
    _save();
  }

  void removeCategory(String c) {
    categories.remove(c);
    _save();
  }

  void reset() {
    txns = [];
    monthlyBudget = 0;
    categories = {'Food': 0, 'Transport': 0, 'Bills': 0};
    _save();
  }

  // ── queries
  List<Txn> inMonth(DateTime m) => txns
      .where((t) => t.date.year == m.year && t.date.month == m.month)
      .toList();

  double sum(Iterable<Txn> l, {required bool expense}) => l
      .where((t) => t.isExpense == expense)
      .fold(0.0, (a, b) => a + b.amount);

  String csv() {
    final b = StringBuffer('date,title,type,category,amount\n');
    for (final t in txns) {
      b.writeln(
          '${t.date.toIso8601String().substring(0, 10)},"${t.title}",${t.isExpense ? 'expense' : 'income'},${t.category},${t.amount}');
    }
    return b.toString();
  }
}

final store = Store();
