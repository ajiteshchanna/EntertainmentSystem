import 'package:flutter/material.dart';
import 'package:lan_media_app/screens/server_connect_screen.dart';

void main() {
  runApp(const LanMediaApp());
}

class LanMediaApp extends StatelessWidget {
  const LanMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LAN Media",
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F14),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const ServerConnectScreen(),
    );
  }
}
