import 'package:flutter/material.dart';
import '../core/config.dart';
import 'media_list_screen.dart';

class ServerConnectScreen extends StatefulWidget {
  const ServerConnectScreen({super.key});

  @override
  State<ServerConnectScreen> createState() => _ServerConnectScreenState();
}

class _ServerConnectScreenState extends State<ServerConnectScreen> {
  final TextEditingController _controller = TextEditingController();

  String status = "";

  // ✅ Your default server
  final String defaultIp = "10.227.238.70:8000";

  void connectToServer() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      setState(() {
        status = "Please enter server IP and port.";
      });
      return;
    }

    AppConfig.baseUrl = "http://$input";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MediaListScreen(baseUrl: AppConfig.baseUrl),
      ),
    );
  }

  void _fillDefaultIp() {
    setState(() {
      _controller.text = defaultIp;
      status = "";
    });
  }

  @override
  void initState() {
    super.initState();

    // ✅ Optional: Auto-fill when screen opens
    _controller.text = defaultIp;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect to Server")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Server IP (e.g. 10.227.238.70:8000)",
                prefixIcon: Icon(Icons.wifi_tethering_rounded),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 14),

            // ✅ Clickable IP Button
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionChip(
                    label: Text(defaultIp),
                    avatar: const Icon(Icons.flash_on_rounded, size: 18),
                    onPressed: _fillDefaultIp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: connectToServer,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text("Connect"),
            ),

            const SizedBox(height: 14),

            Text(
              status,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
