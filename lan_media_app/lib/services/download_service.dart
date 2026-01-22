import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  static Future<String> downloadFile({
    required String url,
    required String fileName,
  }) async {
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to download file: ${response.statusCode}");
    }

    final Directory dir = await getApplicationDocumentsDirectory();
    final String savePath = "${dir.path}/$fileName";

    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);

    return savePath;
  }

  static Future<void> openDownloadedFile(String path) async {
    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      throw Exception("Cannot open file: ${result.message}");
    }
  }
}
