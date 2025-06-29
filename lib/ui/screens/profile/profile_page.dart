import 'package:flutter/material.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  // Displays and manages user profile information
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Loads current username if available
    final userService = Provider.of<UserService>(context, listen: false);
    if (userService.currentUser?.username != null) {
      _usernameController.text = userService.currentUser!.username!;
    }
  }

  @override
  void dispose() {
    // Disposes the controller
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUsername() async {
    // Validates and saves the edited username
    if (_formKey.currentState!.validate()) {
      final userService = Provider.of<UserService>(context, listen: false);
      final username = _usernameController.text.trim();
      
      // First check if the user document exists, create if needed
      final success = await userService.ensureUserDocumentExists();
      if (!success) {
        // ignore: use_build_context_synchronously
        ToastUtils.showErrorToast(context, userService.errorMessage ?? "Failed to create user profile");
        return;
      }
      
      final updateSuccess = await userService.updateUsername(username);
      
      if (updateSuccess) {
        // Force refresh user data to ensure all listeners get the update
        // ignore: use_build_context_synchronously
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.user != null) {
          await userService.fetchUserData(authService.user!.uid);
        }
        
        // ignore: use_build_context_synchronously
        ToastUtils.showSuccessToast(context, "Username updated successfully!");
      } else {
        // ignore: use_build_context_synchronously
        ToastUtils.showErrorToast(context, userService.errorMessage ?? "Failed to update username");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Renders profile information and edit form if enabled
    final userService = Provider.of<UserService>(context);
    final user = userService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            FontAwesomeIcons.circleUser,
                            size: 80,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.email ?? 'No email',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        // Apply the InputDecorationTheme from AppTheme
                        border: Theme.of(context).inputDecorationTheme.border,
                        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                        iconColor: Theme.of(context).inputDecorationTheme.iconColor,
                        prefixIconColor: Theme.of(context).inputDecorationTheme.prefixIconColor,
                        suffixIconColor: Theme.of(context).inputDecorationTheme.suffixIconColor,
                        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton.extended(
                        onPressed: _saveUsername,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        icon: Icon(
                          FontAwesomeIcons.save,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        label: Text(
                          'Save',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
