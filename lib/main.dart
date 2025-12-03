import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const SinterklaasApp());
}

class SinterklaasApp extends StatelessWidget {
  const SinterklaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinterklaas Surprise',
      theme: SinterklaasTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
