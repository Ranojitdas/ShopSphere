import 'package:flutter/material.dart';

/// Entry point of the ShopSphere application.
void main() {
  // Ensure that Flutter widget binding is properly initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShopSphereApp());
}

/// Root widget of the application.
/// Configures high-level app settings, themes, and navigation.
class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'ShopSphere Initializing...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
