import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class YoloDetection {
  const YoloDetection({
    required this.name,
    required this.confidence,
    required this.xmin,
    required this.ymin,
    required this.xmax,
    required this.ymax,
  });

  final String name;
  final double confidence;
  final int xmin;
  final int ymin;
  final int xmax;
  final int ymax;

  factory YoloDetection.fromJson(Map<String, dynamic> json) {
    return YoloDetection(
      name: json["name"]?.toString() ?? "unknown",
      confidence: (json["confidence"] as num?)?.toDouble() ?? 0,
      xmin: (json["xmin"] as num?)?.toInt() ?? 0,
      ymin: (json["ymin"] as num?)?.toInt() ?? 0,
      xmax: (json["xmax"] as num?)?.toInt() ?? 0,
      ymax: (json["ymax"] as num?)?.toInt() ?? 0,
    );
  }
}

class YoloDetectionResponse {
  const YoloDetectionResponse({
    required this.status,
    required this.message,
    required this.objects,
  });

  final String status;
  final String message;
  final List<YoloDetection> objects;

  bool get isSuccess => status == "success";

  factory YoloDetectionResponse.fromJson(Map<String, dynamic> json) {
    final Object? rawObjects = json["objects"];
    final List<YoloDetection> objects = rawObjects is List
        ? rawObjects
            .whereType<Map>()
            .map((object) => YoloDetection.fromJson(
                  Map<String, dynamic>.from(object),
                ))
            .toList()
        : const [];

    return YoloDetectionResponse(
      status: json["status"]?.toString() ?? "error",
      message: json["message"]?.toString() ?? "Respons server tidak valid",
      objects: objects,
    );
  }

  factory YoloDetectionResponse.error(String message) {
    return YoloDetectionResponse(
      status: "error",
      message: message,
      objects: const [],
    );
  }
}

class YoloDetectionService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<YoloDetectionResponse> detectFrame(File imageFile) async {
    final Uri url = Uri.parse("${ApiConfig.baseUrl}/detect-frame");

    try {
      final http.MultipartRequest request = http.MultipartRequest("POST", url);
      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

      final http.StreamedResponse streamedResponse =
          await request.send().timeout(_timeout);
      final http.Response response =
          await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return YoloDetectionResponse.error(
          "Server mengembalikan status ${response.statusCode}",
        );
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return YoloDetectionResponse.error("Format respons server tidak valid");
      }

      return YoloDetectionResponse.fromJson(decoded);
    } on SocketException {
      return YoloDetectionResponse.error(
        "Gagal terhubung ke server. Pastikan API YOLOv5 sudah berjalan.",
      );
    } on TimeoutException {
      return YoloDetectionResponse.error("Koneksi ke YOLOv5 terlalu lama");
    } on FormatException {
      return YoloDetectionResponse.error("Respons server bukan JSON valid");
    } on http.ClientException {
      return YoloDetectionResponse.error("Koneksi ke server terputus");
    } catch (error) {
      return YoloDetectionResponse.error("Gagal deteksi objek: $error");
    }
  }
}
