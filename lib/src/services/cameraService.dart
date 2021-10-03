import 'dart:async';

import 'package:camera/camera.dart';
import 'package:virice/src/services/tensorflowService.dart';

class CameraService {
  // singleton boilderplate
  static final CameraService _cameraService = CameraService._internal();
  factory CameraService() {
    return _cameraService;
  }
  CameraService._internal();
  TensorflowService _tensorflowService = TensorflowService();
  CameraController get cameraController => _cameraController;
  late CameraController _cameraController;
  bool _isStopStream = false;
  bool get isStopStream => this._isStopStream;

  Future startCamera(CameraDescription cameraDescription) {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    return _cameraController.initialize();
  }

  Future<String> takeImage() async {
    XFile file = await _cameraController.takePicture();
    return file.path;
  }

  void dispose() {
    _cameraController.dispose();
  }

  // void pauseCamera() {
  //   _isAvaiable = false;
  // }

  // void resumeCamera() {
  //   _isAvaiable = true;
  // }

  Future<void> startDetection() async {
    _isStopStream = false;
    _cameraController.startImageStream((image) async {
      try {
        if (_tensorflowService.isFinishedPredict) {
          await _tensorflowService.runModelonFrame(image);
        }
      } catch (e) {
        print("Error in camera service: $e");
      }
    });
  }

  Future<void> stopDetection() async {
    await this._cameraController.stopImageStream();
    _tensorflowService.stopPrediction();
    _isStopStream = true;
  }
}
