import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onSwitchToLogin; // Callback to switch back to login
  const RegisterPage({super.key, this.onSwitchToLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controls validation and user input for registration
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller for confirm password input
  bool _obscurePassword = true; // Toggles password visibility
  bool _obscureConfirmPassword = true; // Toggles confirm password visibility

  @override
  void dispose() {
    // Disposes controllers to free resources
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    // Validates form and calls AuthService to register new account
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        // ignore: use_build_context_synchronously
        ToastUtils.showSuccessToast(context, "Registration successful! Welcome to SimpanNow.");
      } else if (mounted) {
        ToastUtils.showErrorToast(context, authService.errorMessage ?? "Registration failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Renders the registration form UI along with feedback messages
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
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
                          FontAwesomeIcons.userPlus,
                          size: 40, // Reduced from 50
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
                          'Create your account to start managing your finances',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(FontAwesomeIcons.lock, size: 14),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: Icon(_obscureConfirmPassword
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                                    size: 14),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: authService.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: authService.isLoading
                              ? const SizedBox.shrink()
                              : const Icon(FontAwesomeIcons.userPlus),
                          label: authService.isLoading
                              ? const SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 24.0,
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            // Switches to login using onSwitchToLogin when available
                            if (widget.onSwitchToLogin != null) {
                              widget.onSwitchToLogin!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.rightToBracket, size: 16),
                          label: const Text('Already have an account? Login'),
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
