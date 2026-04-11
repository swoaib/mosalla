import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mosalla_repository.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _logoController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isSuccess = false;
    });
    try {
      final authRepo = context.read<AuthRepository>();
      final mosallaRepo = context.read<MosallaRepository>();

      if (_isLogin) {
        await authRepo.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Registration
        final cred = await authRepo.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (cred.user != null) {
          await mosallaRepo.createMosallaProfile(cred.user!.uid, {
            'name': _nameController.text.trim(),
            'yearFounded': _yearController.text.trim(),
            'logo': _logoController.text.trim(),
            'location': '',
            'description': '',
          });
          if (mounted) {
            setState(() {
              _isLogin = true;
              _isSuccess = true;
              _statusMessage =
                  'Verification email sent! Please check your inbox.';
            });
            return;
          }
        }
      }
      // Reactivity is handled dynamically by main StreamBuilder routes.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          if (e.code == 'email-not-verified') {
            _statusMessage =
                'Please verify your email address before signing in. Check your inbox for the verification link.';
          } else {
            _statusMessage = e.message ?? e.toString();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _statusMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectYear() async {
    final int? currentYear = int.tryParse(_yearController.text);
    final DateTime initialDate = currentYear != null
        ? DateTime(currentYear)
        : DateTime(DateTime.now().year);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year Founded"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1800),
              lastDate: DateTime.now(),
              selectedDate: initialDate,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _yearController.text = dateTime.year.toString();
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            key: const PageStorageKey('admin_login_form'),
            padding: const EdgeInsets.all(32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                    'assets/icon/logo_dark.png',
                    height: 150),
                Text(
                  _isLogin ? 'Admin Login' : 'Create Admin Account',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                  ),
                  obscureText: true,
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Mosalla Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Mosalla Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _yearController,
                    readOnly: true,
                    onTap: _selectYear,
                    decoration: InputDecoration(
                      labelText: 'Year Founded',
                      prefixIcon: const Icon(Icons.calendar_today, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _logoController,
                    decoration: InputDecoration(
                      labelText: 'Logo URL (optional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (_statusMessage.isNotEmpty) ...[
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green : Colors.red,
                      fontWeight:
                          _isSuccess ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isLogin ? 'Login' : 'Register',
                          style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _statusMessage = '';
                      _isSuccess = false;
                    });
                  },
                  child: Text(_isLogin
                      ? 'No account? Register here.'
                      : 'Already have an account? Login.'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
