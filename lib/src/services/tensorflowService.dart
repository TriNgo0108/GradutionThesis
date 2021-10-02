import 'dart:async';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TensorflowService {
  //singleton boilerplate
  static final TensorflowService _tensorflowService =
      TensorflowService._internal();
  factory TensorflowService() {
    return _tensorflowService;
  }
  //
  TensorflowService._internal();
  StreamController<int> _classiferController = StreamController();
  Stream get classiferController => this._classiferController.stream;
  bool _isLoaded = false;
  bool _firstInit = true;

  bool isFirstInit() => _firstInit;

  void createNewstream() {
    this._classiferController = StreamController();
  }

  bool isClosedStream() {
    return _classiferController.isClosed;
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/res/model.tflite", labels: "assets/res/labels.txt");
      _isLoaded = true;
    } catch (e) {
      print("Error in TensorflowService: $e ");
    }
  }

  Future<void> runModelonFrame(CameraImage img) async {
    if (_isLoaded) {
      var classifies = await Tflite.runModelOnFrame(
          bytesList: img.planes.map((plane) => plane.bytes).toList(),
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 0.0,
          imageStd: 255.0,
          threshold: 0.2,
          numResults: 1);
      if (classifies != null) {
        int predictionIndex = classifies[0]["index"];
        this._classiferController.add(predictionIndex);
      }
    }
  }

  Future<int> runModelonImage(String path) async {
    if (_isLoaded) {
      var classifies = await Tflite.runModelOnImage(
          path: path,
          imageMean: 0.0,
          imageStd: 255.0,
          threshold: 0.2,
          numResults: 1);
      if (classifies != null) {
        print("Prediction result: ${classifies[0]["index"]}");
        int predictionIndex = classifies[0]["index"];
        return predictionIndex;
      }
    }
    return 4;
  }

  stopPrediction() {
    if (!this._classiferController.isClosed) {
      this._classiferController.close();
      print("stream State ${this._classiferController.isClosed}");
      _firstInit = false;
    }
  }
}
