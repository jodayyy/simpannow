import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/ui/screens/auth/register_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onSwitchToRegister; // Callback to switch over to registration
  const LoginPage({super.key, this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Manages form validation, text inputs, and loading states
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = true;

  @override
  void initState() {
    // Initialize, try to load saved email for autofill
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    // Fetches any previously saved email from AuthService
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final savedEmail = await authService.getSavedEmail();
    
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    // Disposes controllers properly
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // Validates user credentials and attempts login
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? "Login failed"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Returns the main login UI, including “Remember me” and “Forgot Password”
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                FontAwesomeIcons.piggyBank,
                                size: 45,
                                color: Theme.of(context).iconTheme.color, // Updated to dynamic color
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'SimpanNow',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.headlineMedium?.color, // Updated to dynamic color
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Your Personal Finance Companion',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color, // Updated to dynamic color
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(FontAwesomeIcons.envelope, size: 14),
                                  border: Theme.of(context).inputDecorationTheme.border,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                enableSuggestions: true,
                                autofillHints: const [AutofillHints.email, AutofillHints.username],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(FontAwesomeIcons.lock, size: 14),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? FontAwesomeIcons.eyeSlash
                                          : FontAwesomeIcons.eye,
                                          size: 14),
                                      onPressed: () {
                                        // Toggles password visibility
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                obscureText: _obscurePassword,
                                autocorrect: false,
                                enableSuggestions: false,
                                autofillHints: const [AutofillHints.password],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                // "Remember me" checkbox
                                children: [
                                  Checkbox(
                                    value: authService.rememberMe,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        authService.rememberMe = value;
                                      }
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    checkColor: Theme.of(context).colorScheme.surface // Updated to dynamic color
                                  ),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color, // Updated to dynamic color
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // Future feature: forgot password
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Password reset feature coming soon"),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color, // Updated to dynamic color
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: authService.isLoading ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    // On web, this helps with autofill
                                    if (kIsWeb) {
                                      // Workaround for web
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                    _login();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: authService.isLoading
                                    ? const SizedBox.shrink()
                                    : const Icon(FontAwesomeIcons.rightToBracket),
                                label: authService.isLoading
                                    ? const SpinKitFadingCircle(
                                        color: Colors.white,
                                        size: 24.0,
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              TextButton.icon(
                                onPressed: () {
                                  // Switches to register page (or callback) if user doesn’t have an account
                                  if (widget.onSwitchToRegister != null) {
                                    widget.onSwitchToRegister!();
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage(),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(FontAwesomeIcons.userPlus, size: 16),
                                label: const Text('Don\'t have an account? Register now'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
