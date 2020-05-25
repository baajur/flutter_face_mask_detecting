import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_face_mask_detecting/overlay.dart' as ol;
import 'package:tflite/tflite.dart';
import 'dart:math';

class CameraPage extends StatefulWidget {
  const CameraPage({
    @required List<CameraDescription> cameras,
  })  : assert(cameras != null),
        _cameras = cameras;

  final List<CameraDescription> _cameras;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController _controller;
  bool _isDetecting = false;

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget._cameras == null || widget._cameras.isEmpty) {
      print('No camera is found');
    } else {
      _setupCamera();
    }
  }

  bool _updateCamera() {
    if (!mounted) {
      return false;
    }
    setState(() {});
    return true;
  }

  void _updateRecognitions({
    List<dynamic> recognitions,
    int imageWidth,
    int imageHeight,
  }) {
    setState(() {
      _recognitions = recognitions;
      _imageWidth = imageWidth;
      _imageHeight = imageHeight;
    });
  }

  void _readFrames() {
    _controller.startImageStream(
      (CameraImage img) {
        if (!_isDetecting) {
          _isDetecting = true;

          Tflite.runModelOnFrame(
            bytesList: img.planes.map((Plane plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: img.height,
            imageWidth: img.width,
            numResults: 2,
          ).then((List<dynamic> recognitions) {
            _updateRecognitions(
              recognitions: recognitions,
              imageWidth: img.width,
              imageHeight: img.height,
            );
            _isDetecting = false;
          });
        }
      },
    );
  }

  void _setupCamera() {
    _controller = CameraController(
      widget._cameras[0],
      ResolutionPreset.high,
    );
    _controller.initialize().then((_) {
      if (_updateCamera()) {
        _readFrames();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    final Size screen = MediaQuery.of(context).size;
    final double screenH = max(screen.height, screen.width);
    final double screenW = min(screen.height, screen.width);

    final Size previewSize = _controller.value.previewSize;
    final double previewH = max(previewSize.height, previewSize.width);
    final double previewW = min(previewSize.height, previewSize.width);
    final double screenRatio = screenH / screenW;
    final double previewRatio = previewH / previewW;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            OverflowBox(
              maxHeight: screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
              maxWidth: screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
              child: CameraPreview(_controller),
            ),
            ol.Overlay(
              results: _recognitions ?? <dynamic>[],
              previewH: max(_imageHeight, _imageWidth),
              previewW: min(_imageHeight, _imageWidth),
              screenH: screen.height,
              screenW: screen.width,
            )
          ],
        ),
      ),
    );
  }
}