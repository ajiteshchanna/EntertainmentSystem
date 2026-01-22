import 'package:flutter/material.dart';
import '../services/download_service.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  Future<void> _download(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading...")),
      );

      final savedPath = await DownloadService.downloadFile(
        url: imageUrl,
        fileName: title,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved: $savedPath")),
      );

      await DownloadService.openDownloadedFile(savedPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _download(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text("Failed to load image"),
          ),
        ),
      ),
    );
  }
}
