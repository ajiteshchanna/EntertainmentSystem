import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String baseUrl;
  const HomeScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LAN Media"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              "Welcome 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 18),

            Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            _DummyRow(),

            SizedBox(height: 18),
            Text("Recent Videos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            _DummyRow(),

            SizedBox(height: 18),
            Text("Audio Library", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            _DummyRow(),
          ],
        ),
      ),
    );
  }
}

class _DummyRow extends StatelessWidget {
  const _DummyRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text("Card ${i + 1}")),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 6,
      ),
    );
  }
}
