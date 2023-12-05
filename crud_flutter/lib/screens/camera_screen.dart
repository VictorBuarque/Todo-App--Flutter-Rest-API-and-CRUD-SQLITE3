import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final CameraController cameraController;

  const CameraScreen({Key? key, required this.cameraController})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await widget.cameraController.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: _cameraPreviewWidget(),
    );
  }

  Widget _cameraPreviewWidget() {
    if (widget.cameraController == null || !widget.cameraController.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: widget.cameraController.value.aspectRatio,
      child: CameraPreview(widget.cameraController),
    );
  }

  @override
  void dispose() {
    widget.cameraController.dispose();
    super.dispose();
  }
}
