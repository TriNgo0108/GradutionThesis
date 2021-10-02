import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart';

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

  // convert YU420toImageColor, just covert image when _isSavedImage = true
  // Future<void> convertYUV420toImageColor(CameraImage image) async {
  //   if (_isSavedImage) {
  //     try {
  //       final int width = image.width;
  //       final int height = image.height;
  //       final int uvRowStride = image.planes[1].bytesPerRow;
  //       final int? uvPixelStride = image.planes[1].bytesPerPixel;

  //       print("uvRowStride: " + uvRowStride.toString());
  //       print("uvPixelStride: " + uvPixelStride.toString());

  //       // imgLib -> Image package from https://pub.dartlang.org/packages/image
  //       var img = Image(width, height); // Create Image buffer

  //       // Fill image buffer with plane[0] from YUV420_888
  //       for (int x = 0; x < width; x++) {
  //         for (int y = 0; y < height; y++) {
  //           final int uvIndex = uvPixelStride! * (x / 2).floor() +
  //               uvRowStride * (y / 2).floor();
  //           final int index = y * width + x;

  //           final yp = image.planes[0].bytes[index];
  //           final up = image.planes[1].bytes[uvIndex];
  //           final vp = image.planes[2].bytes[uvIndex];
  //           // Calculate pixel color
  //           int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
  //           int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
  //               .round()
  //               .clamp(0, 255);
  //           int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
  //           // color: 0x FF  FF  FF  FF
  //           //           A   B   G   R
  //           img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
  //         }
  //       }

  //       PngEncoder pngEncoder = new PngEncoder(level: 0, filter: 0);
  //       List<int> png = pngEncoder.encodeImage(img);
  //       Uint8List u8List = Uint8List.fromList(png);
  //       this._imageController.add(u8List);
  //       _isSavedImage = false;
  //     } catch (e) {
  //       print(">>>>>>>>>>>> ERROR:" + e.toString());
  //     }
  //   }
  // }

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

  Future<void> runModelonImage(String? path) async {
    if (_isLoaded) {
      var classifies = await Tflite.runModelOnImage(
          path: path as String,
          imageMean: 0.0,
          imageStd: 255.0,
          threshold: 0.2,
          numResults: 1);
      if (classifies != null) {
        if (this._classiferController.isClosed) {
          this._classiferController = new StreamController();
        }
        print("Prediction result: ${classifies[0]["index"]}");
        int predictionIndex = classifies[0]["index"];
        this._classiferController.add(predictionIndex);
      }
    }
  }

  stopPrediction() {
    if (!this._classiferController.isClosed) {
      this._classiferController.close();
      print("stream State ${this._classiferController.isClosed}");
      _firstInit = false;
    }
  }
}
