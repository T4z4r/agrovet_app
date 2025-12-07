import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String role = 'seller';
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true),
          TextField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true),
          DropdownButtonFormField<String>(
            value: role,
            items: const [
              DropdownMenuItem(value: 'seller', child: Text('Seller')),
              DropdownMenuItem(value: 'owner', child: Text('Owner')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => setState(() {
              role = v ?? 'seller';
            }),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);
                      try {
                        final res = await auth.register(_name.text.trim(),
                            _email.text.trim(), _password.text.trim(), role);
                        if (res.containsKey('token')) {
                          Navigator.pop(context);
                        } else {
                          setState(() =>
                              error = res['message'] ?? 'Register failed');
                        }
                      } catch (e) {
                        setState(() => error = e.toString());
                      }
                      setState(() => loading = false);
                    },
              child: const Text('Register')),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}
