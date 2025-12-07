import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/dashboard_screen.dart';
import '../widgets/loading_widget.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('AgroVet - Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true),
          const SizedBox(height: 16),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                      error = null;
                    });
                    try {
                      final res = await auth.login(
                          _email.text.trim(), _password.text.trim());
                      if (res.containsKey('token')) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DashboardScreen()));
                      } else {
                        setState(() {
                          error = res['message'] ?? 'Login failed';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                      });
                    } finally {
                      setState(() {
                        loading = false;
                      });
                    }
                  },
            child: loading ? const LoadingWidget() : const Text('Login'),
          ),
          TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Register'))
        ]),
      ),
    );
  }
}
