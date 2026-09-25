import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const PhantomREApp());
}

class PhantomREApp extends StatelessWidget {
  const PhantomREApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhantomRE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomePage(),
    );
  }
}
