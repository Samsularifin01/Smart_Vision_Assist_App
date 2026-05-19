import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/tts_service.dart';
import '../services/yolo_detection_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  final YoloDetectionService _detectionService = YoloDetectionService();
  final TTSService _tts = TTSService();

  bool isRecording = false;
  bool isDetecting = false;
  String statusMessage = "Tekan tombol rekam untuk mulai deteksi";
  List<YoloDetection> detectedObjects = const [];
  Size? detectionFrameSize;
  Timer? _detectionTimer;
  Timer? _vibrationTimer;
  bool _isVibrating = false;
  String _lastSpokenMessage = "";
  DateTime? _lastSpokenAt;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        setState(() {
          statusMessage = "Kamera tidak ditemukan";
        });
        await _tts.speak(statusMessage);
        return;
      }

      controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(() {
        statusMessage = "Gagal membuka kamera: $error";
      });
      await _tts.speak("Gagal membuka kamera");
    }
  }

  Future<void> startRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null ||
        !cameraController.value.isInitialized ||
        isRecording) {
      return;
    }

    setState(() {
      isRecording = true;
      statusMessage = "Deteksi dimulai";
      detectedObjects = const [];
      detectionFrameSize = null;
    });
    await _tts.speak("Deteksi dimulai");

    await _detectCurrentFrame();
    _detectionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && isRecording && !isDetecting) {
        _detectCurrentFrame();
      }
    });
  }

  Future<void> stopRecording() async {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    _isVibrating = false;

    if (!mounted) return;
    setState(() {
      isRecording = false;
      isDetecting = false;
      statusMessage = "Deteksi dihentikan";
      detectedObjects = const [];
      detectionFrameSize = null;
    });
    await _tts.speak("Deteksi dihentikan");
  }

  Future<void> _detectCurrentFrame() async {
    final CameraController? cameraController = controller;
    if (cameraController == null ||
        !cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture ||
        isDetecting) {
      return;
    }

    setState(() {
      isDetecting = true;
      statusMessage = "Mengambil frame kamera...";
    });

    File? capturedFile;

    try {
      final XFile frame = await cameraController.takePicture();
      capturedFile = File(frame.path);
      final Size capturedImageSize = await _readImageSize(capturedFile);

      if (!mounted || !isRecording) return;
      setState(() {
        statusMessage = "Mengirim frame ke YOLOv5...";
      });

      final YoloDetectionResponse response =
          await _detectionService.detectFrame(capturedFile);

      if (!mounted || !isRecording) return;
      setState(() {
        detectedObjects = response.objects;
        detectionFrameSize = capturedImageSize;
        statusMessage = response.message;
      });

      await _announceDetection(response);
    } catch (error) {
      if (!mounted || !isRecording) return;
      const String message = "Gagal memproses frame kamera";
      setState(() {
        statusMessage = "$message: $error";
      });
      await _speakOnce(message);
    } finally {
      if (capturedFile != null && await capturedFile.exists()) {
        try {
          await capturedFile.delete();
        } catch (_) {
          // File sementara bisa saja sudah dibersihkan oleh sistem.
        }
      }

      if (mounted) {
        setState(() {
          isDetecting = false;
        });
      }
    }
  }

  Future<Size> _readImageSize(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return Size(
      frameInfo.image.width.toDouble(),
      frameInfo.image.height.toDouble(),
    );
  }

  Future<void> _announceDetection(YoloDetectionResponse response) async {
    if (!response.isSuccess) {
      await _speakOnce(response.message);
      return;
    }

    if (response.objects.isEmpty) {
      await _speakOnce("Tidak ada objek terdeteksi");
      return;
    }

    _vibrateForTwoSeconds();

    final Map<String, int> objectCounts = {};
    for (final YoloDetection object in response.objects) {
      objectCounts[object.name] = (objectCounts[object.name] ?? 0) + 1;
    }

    final String objectSummary = objectCounts.entries
        .map(
          (entry) => entry.value > 1 ? "${entry.value} ${entry.key}" : entry.key,
        )
        .join(", ");

    await _speakOnce("Terdeteksi $objectSummary");
  }

  void _vibrateForTwoSeconds() {
    if (_isVibrating) {
      return;
    }

    _isVibrating = true;
    int vibrationCount = 0;
    const int maxVibrationCount = 8;
    const Duration vibrationInterval = Duration(milliseconds: 250);

    HapticFeedback.vibrate();
    vibrationCount++;

    _vibrationTimer?.cancel();
    _vibrationTimer = Timer.periodic(vibrationInterval, (Timer timer) {
      if (!mounted || !isRecording || vibrationCount >= maxVibrationCount) {
        timer.cancel();
        _isVibrating = false;
        return;
      }

      HapticFeedback.vibrate();
      vibrationCount++;
    });
  }

  Future<void> _speakOnce(String message) async {
    final DateTime now = DateTime.now();
    final bool canRepeat = _lastSpokenAt == null ||
        now.difference(_lastSpokenAt!) > const Duration(seconds: 5);

    if (message == _lastSpokenMessage && !canRepeat) {
      return;
    }

    _lastSpokenMessage = message;
    _lastSpokenAt = now;
    await _tts.speak(message);
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _vibrationTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  Widget buildCameraPreview() {
    final Size? previewSize = controller?.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller!);
    }

    final double previewAspectRatio = previewSize.height / previewSize.width;

    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewSize.width,
                height: previewSize.width / previewAspectRatio,
                child: CameraPreview(controller!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: statusMessage == "Tekan tombol rekam untuk mulai deteksi"
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: buildCameraPreview(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _BoundingBoxOverlay(
                imageSize: detectionFrameSize,
                objects: detectedObjects,
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: _DetectionStatusPanel(
              isRecording: isRecording,
              isDetecting: isDetecting,
              statusMessage: statusMessage,
              objects: detectedObjects,
            ),
          ),
          Positioned(
            bottom: 40,
            right: 30,
            child: Semantics(
              label: "Kembali",
              button: true,
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: Semantics(
              label: isRecording ? "Stop rekam" : "Mulai rekam",
              button: true,
              child: GestureDetector(
                onTap: () {
                  if (isRecording) {
                    stopRecording();
                  } else {
                    startRecording();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.grey, width: 4),
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.circle,
                    color: isRecording ? Colors.white : Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoundingBoxOverlay extends StatelessWidget {
  const _BoundingBoxOverlay({
    required this.imageSize,
    required this.objects,
  });

  final Size? imageSize;
  final List<YoloDetection> objects;

  @override
  Widget build(BuildContext context) {
    if (imageSize == null || objects.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _BoundingBoxPainter(
        imageSize: imageSize!,
        objects: objects,
      ),
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  _BoundingBoxPainter({
    required this.imageSize,
    required this.objects,
  });

  final Size imageSize;
  final List<YoloDetection> objects;

  static const double _previewAspectRatio = 9 / 16;
  static const List<Color> _boxColors = [
    Color(0xFF00E676),
    Color(0xFFFFD600),
    Color(0xFF40C4FF),
    Color(0xFFFF4081),
    Color(0xFFFF9100),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return;
    }

    final Rect previewRect = _centeredAspectRect(size, _previewAspectRatio);
    final double scale = _coverScale(imageSize, previewRect.size);
    final Size scaledImageSize = Size(
      imageSize.width * scale,
      imageSize.height * scale,
    );
    final Offset imageOffset = Offset(
      previewRect.left + (previewRect.width - scaledImageSize.width) / 2,
      previewRect.top + (previewRect.height - scaledImageSize.height) / 2,
    );

    canvas.save();
    canvas.clipRect(previewRect);

    for (int index = 0; index < objects.length; index++) {
      final YoloDetection object = objects[index];
      final Color color = _boxColors[index % _boxColors.length];
      final Rect box = Rect.fromLTRB(
        imageOffset.dx + object.xmin * scale,
        imageOffset.dy + object.ymin * scale,
        imageOffset.dx + object.xmax * scale,
        imageOffset.dy + object.ymax * scale,
      );

      if (box.width <= 0 || box.height <= 0) {
        continue;
      }

      _drawBox(canvas, previewRect, box, color, object);
    }

    canvas.restore();
  }

  void _drawBox(
    Canvas canvas,
    Rect previewRect,
    Rect box,
    Color color,
    YoloDetection object,
  ) {
    final Paint shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.black.withOpacity(0.55);
    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color;

    canvas.drawRect(box, shadowPaint);
    canvas.drawRect(box, boxPaint);

    final String label = "${object.name} ${(object.confidence * 100).round()}%";
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: previewRect.width - 16);

    final double labelWidth = textPainter.width + 12;
    final double labelHeight = textPainter.height + 8;
    double labelLeft = box.left;
    double labelTop = box.top - labelHeight;

    if (labelTop < previewRect.top) {
      labelTop = box.top;
    }
    if (labelLeft + labelWidth > previewRect.right) {
      labelLeft = previewRect.right - labelWidth;
    }
    labelLeft =
        labelLeft.clamp(previewRect.left, previewRect.right - labelWidth).toDouble();

    final RRect labelBackground = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelLeft, labelTop, labelWidth, labelHeight),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      labelBackground,
      Paint()..color = color.withOpacity(0.92),
    );
    textPainter.paint(
      canvas,
      Offset(labelLeft + 6, labelTop + 4),
    );
  }

  Rect _centeredAspectRect(Size containerSize, double aspectRatio) {
    final double containerRatio = containerSize.width / containerSize.height;

    if (containerRatio > aspectRatio) {
      final double width = containerSize.height * aspectRatio;
      final double left = (containerSize.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, containerSize.height);
    }

    final double height = containerSize.width / aspectRatio;
    final double top = (containerSize.height - height) / 2;
    return Rect.fromLTWH(0, top, containerSize.width, height);
  }

  double _coverScale(Size source, Size destination) {
    final double scaleX = destination.width / source.width;
    final double scaleY = destination.height / source.height;
    return scaleX > scaleY ? scaleX : scaleY;
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.objects != objects;
  }
}

class _DetectionStatusPanel extends StatelessWidget {
  const _DetectionStatusPanel({
    required this.isRecording,
    required this.isDetecting,
    required this.statusMessage,
    required this.objects,
  });

  final bool isRecording;
  final bool isDetecting;
  final String statusMessage;
  final List<YoloDetection> objects;

  @override
  Widget build(BuildContext context) {
    final List<YoloDetection> visibleObjects = objects.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRecording ? Icons.radio_button_checked : Icons.videocam,
                color: isRecording ? Colors.redAccent : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDetecting ? "YOLOv5 sedang berjalan..." : statusMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (visibleObjects.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final YoloDetection object in visibleObjects)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "${object.name} - ${(object.confidence * 100).round()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
