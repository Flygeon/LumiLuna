import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(
      title: '我的',
      showTrashEntry: true,
    );
  }
}
