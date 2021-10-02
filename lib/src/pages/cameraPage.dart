import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virice/src/routes/routeName.dart';
import 'package:virice/src/services/cameraService.dart';
import 'package:virice/src/services/tensorflowService.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription cameraDescription;
  const CameraPage({Key? key, required this.cameraDescription})
      : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TensorflowService _tensorflowService = TensorflowService();
  CameraService _cameraService = CameraService();
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initialService();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _controller.repeat(reverse: true);
  }

  initialService() async {
    try {
      await _cameraService.startCamera(widget.cameraDescription);
      setState(() {});
      _tensorflowService.loadModel();
      _cameraService.startDetection();
      checkStream();
    } catch (e) {
      print("Error here $e");
    }
  }

  checkStream() {
    // if (_tensorflowService.isFirstInit()) {
    //   _tensorflowService.classiferController.listen((event) async {
    //     subscription(event);
    //   });
    // }
    if (_tensorflowService.isClosedStream()) {
      _tensorflowService.createNewstream();
      _cameraService.resumeCamera();
      subscription();
    } else {
      subscription();
    }
  }

  subscription() {
    _tensorflowService.classiferController.listen((event) {
      if (event == 4) {
        print(">>>>>>>>>>>>>>This object isn't a rice ");
        _cameraService.pauseCamera();
        _showDialog();
      }
    });
  }

  stopService() async {
    await _cameraService.stopDetection();
    _tensorflowService.stopPrediction();
    print(">>>>>>>>Stop");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    stopService();
    super.dispose();
    print(">>>>>>>>>dispose");
  }

  bool _isTryButton(Color color) => color == Colors.green;
  void onPressTryButton() {
    Navigator.of(context).pop();
    _cameraService.resumeCamera();
  }

  void onPressExitButton() {
    Navigator.popUntil(
        context, (route) => route.settings.name == RouteName.HOME_PAGE);
  }

  Future<bool> _onWillPop() async {
    _cameraService.resumeCamera();
    print(">>>>>>>>>>resume");
    Navigator.of(context).pop(true);
    return Future.value(true);
  }

  Widget _dialogButton(
      Color color, Function onPress, String label, Color backgroundColor) {
    bool isTryButton = _isTryButton(color);

    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            side: MaterialStateProperty.all(BorderSide(color: color)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)))),
        onPressed: () {
          onPress();
        },
        child: Text(
          label,
          style: TextStyle(
              fontSize: 18, color: !isTryButton ? Colors.white : color),
        ));
  }

  Future<void> _showDialog() {
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Dialog(
              insetAnimationCurve: Curves.easeIn,
              insetAnimationDuration: const Duration(microseconds: 350),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.only(
                      //     left: 10, top: 35 + 10, right: 10, bottom: 10),
                      padding: EdgeInsets.fromLTRB(10, 45, 10, 10),
                      margin: EdgeInsets.only(top: 45),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 10),
                                blurRadius: 10),
                          ]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Text(
                              "Kết quả dự đoán",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 22),
                            child: Text(
                              "Đối tượng dự đoán không phải là lá lúa. \n Vui lòng thử lại !",
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _dialogButton(Colors.green, onPressTryButton,
                                  "Thử lại", Colors.transparent),
                              _dialogButton(Colors.red, onPressExitButton,
                                  "Thoát", Colors.red)
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 45,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(45)),
                            child: Image.asset("assets/img/error.png")),
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      CameraPreview(
        _cameraService.cameraController,
      ),
      Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Di chuyển đến lá lúa cần dự đoán",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              );
            },
          ))
    ]);
  }
}
