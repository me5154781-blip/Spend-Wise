import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/store.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  late bool isLogin = store.hasAccount; // أول مرة = Register، بعد كده = Login
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  bool hide = true;

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: kMuted),
        suffixIcon: suffix,
        filled: true,
        fillColor: kCard,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kOrange)),
      );

  void submit() {
    if (!_form.currentState!.validate()) return;
    if (isLogin) {
      final ok = store.login(email.text, pass.text);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong email or password')));
      }
    } else {
      store.register(name.text.trim(), email.text.trim(), pass.text);
    }
    // لو نجح، store.loggedIn بقى true و ExpenseApp هيوديك للـ Home تلقائيًا
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: kOrange, borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.account_balance_wallet,
                      size: 36, color: Colors.black),
                ),
                const SizedBox(height: 20),
                Text(isLogin ? 'Welcome back' : 'Create account',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                    isLogin
                        ? 'Login to continue tracking your money'
                        : 'Sign up to start tracking your expenses',
                    style: const TextStyle(color: kMuted, fontSize: 13)),
                const SizedBox(height: 28),
                if (!isLogin) ...[
                  TextFormField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Full name', Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec('Email', Icons.mail_outline),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    return (t.contains('@') && t.contains('.'))
                        ? null
                        : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: pass,
                  obscureText: hide,
                  decoration: _dec('Password', Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                            hide ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: kMuted),
                        onPressed: () => setState(() => hide = !hide),
                      )),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirm,
                    obscureText: hide,
                    decoration:
                        _dec('Confirm password', Icons.lock_outline),
                    validator: (v) =>
                        v != pass.text ? "Passwords don't match" : null,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: kOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    onPressed: submit,
                    child: Text(isLogin ? 'Login' : 'Sign up',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    isLogin = !isLogin;
                    _form.currentState?.reset();
                  }),
                  child: Text(
                      isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Login',
                      style: const TextStyle(color: kOrange)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
