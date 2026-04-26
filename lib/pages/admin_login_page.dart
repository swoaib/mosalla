import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mosalla_repository.dart';
import '../widgets/location_search_dialog.dart';
import '../l10n/generated/app_localizations.dart';

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
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

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
        final name = _nameController.text.trim();
        final year = _yearController.text.trim();
        final location = _locationController.text.trim();
        final lat = double.tryParse(_latController.text.trim());
        final lng = double.tryParse(_lngController.text.trim());

        if (name.isEmpty ||
            year.isEmpty ||
            location.isEmpty ||
            lat == null ||
            lng == null) {
          setState(() {
            _isLoading = false;
            _statusMessage =
                'All fields including Location are mandatory.';
          });
          return;
        }

        final cred = await authRepo.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (cred.user != null) {
          await mosallaRepo.createMosallaProfile(cred.user!.uid, {
            'name': name,
            'yearFounded': year,
            'logo': _logoController.text.trim().isNotEmpty
                ? _logoController.text.trim()
                : null,
            'location': location,
            'latitude': lat,
            'longitude': lng,
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

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (email.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your email to reset password.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.sendPasswordResetEmail(email);
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _statusMessage = l10n.passwordResetEmailSent(email);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _statusMessage = l10n.errorSendingPasswordReset;
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
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const LocationSearchDialog(),
    );
    if (result != null) {
      setState(() {
        _locationController.text = result['address'] as String;
        _latController.text = result['lat'].toString();
        _lngController.text = result['lng'].toString();
      });
    }
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
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _forgotPassword,
                      child: Text(
                        AppLocalizations.of(context)?.forgotPassword ?? 'Forgot Password?',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  const Text('Location',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_locationController.text.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.place,
                                  color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _locationController.text,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text('No location set',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _searchLocation,
                            icon: const Icon(Icons.search),
                            label: Text(_locationController.text.isEmpty
                                ? 'Search Location'
                                : 'Change Location'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
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
