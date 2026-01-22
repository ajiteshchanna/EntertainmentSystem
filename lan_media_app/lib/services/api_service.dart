import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../core/config.dart';
import '../models/media_model.dart';

class ApiService {
  static Future<List<MediaModel>> fetchMediaFiles() async {
    final String base = AppConfig.baseUrl.trim();

    if (base.isEmpty) {
      throw Exception("Base URL is empty. Please connect again.");
    }

    final Uri url = Uri.parse("$base/api/files");

    print("✅ FETCHING: $url");

    try {
      final client = http.Client();

      final response = await client
          .get(url, headers: {"Connection": "close"})
          .timeout(const Duration(seconds: 30));

      client.close();

      print("✅ STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => MediaModel.fromJson(e)).toList();
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      throw Exception("Network error: ${e.message}");
    } on HttpException catch (e) {
      throw Exception("HTTP error: ${e.message}");
    } on FormatException {
      throw Exception("Invalid response format from server.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again.");
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }
}
