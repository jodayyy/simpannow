import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:simpannow/core/services/auth_service.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService authService;
  const TopBar({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        children: [
          Icon(FontAwesomeIcons.piggyBank, size: 20),
          SizedBox(width: 10),
          Text('SimpanNow'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.bell),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.rightFromBracket),
          onPressed: () {
            authService.signOut();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}