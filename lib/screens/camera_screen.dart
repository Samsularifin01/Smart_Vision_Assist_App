import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      cameras![0],
      ResolutionPreset.high,
    );

    await controller!.initialize();
    setState(() {});
  }

  // 🔴 START RECORD
  Future<void> startRecording() async {
    if (!controller!.value.isRecordingVideo) {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    }
  }

  // ⏹ STOP RECORD
  Future<void> stopRecording() async {
    if (controller!.value.isRecordingVideo) {
      await controller!.stopVideoRecording();
      setState(() {
        isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget buildCameraPreview() {
    final previewSize = controller?.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller!);
    }

    // Kamera biasanya memberikan rasio landscape, ubah ke portrait 9:16
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 📷 PREVIEW KAMERA (FULL SCREEN)
          Positioned.fill(
            child: buildCameraPreview(),
          ),

          // 🔙 TOMBOL KEMBALI (KANAN BAWAH)
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
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),

          // 🔘 TOMBOL RECORD (TENGAH BAWAH)
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