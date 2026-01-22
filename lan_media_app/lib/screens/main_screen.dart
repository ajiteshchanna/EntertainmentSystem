import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'media_list_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final String baseUrl;
  const MainScreen({super.key, required this.baseUrl});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(baseUrl: widget.baseUrl),
      MediaListScreen(baseUrl: widget.baseUrl),
      const DownloadsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.video_library), label: "Browse"),
          NavigationDestination(icon: Icon(Icons.download), label: "Downloads"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
