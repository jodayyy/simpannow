import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/auth_service.dart';

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
  bool _isEditing = false;

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

  void _toggleEdit() {
    // Toggles between view mode and edit mode
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveUsername() async {
    // Validates and saves the edited username
    if (_formKey.currentState!.validate()) {
      final userService = Provider.of<UserService>(context, listen: false);
      final username = _usernameController.text.trim();
      
      // First check if the user document exists, create if needed
      final success = await userService.ensureUserDocumentExists();
      if (!success) {
        Fluttertoast.showToast(
          msg: userService.errorMessage ?? "Failed to create user profile",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
      
      final updateSuccess = await userService.updateUsername(username);
      
      if (updateSuccess) {
        // Force refresh user data to ensure all listeners get the update
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.user != null) {
          await userService.fetchUserData(authService.user!.uid);
        }
        
        Fluttertoast.showToast(
          msg: "Username updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        setState(() {
          _isEditing = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: userService.errorMessage ?? "Failed to update username",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(FontAwesomeIcons.penToSquare),
              onPressed: _toggleEdit,
            ),
        ],
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
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isEditing
                      ? TextFormField(
                          controller: _usernameController,
                          // Username field for editing
                          decoration: const InputDecoration(
                            hintText: 'Enter your username',
                            border: UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        )
                      : Text(
                          user?.username ?? 'No username set',
                          // Displays existing username if not editing
                          style: const TextStyle(fontSize: 16),
                        ),
                    const Spacer(),
                    if (_isEditing)
                      Row(
                        // Buttons to cancel or save edits
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _toggleEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: _saveUsername,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
