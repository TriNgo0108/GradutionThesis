import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:virice/src/routes/routeName.dart';
import 'package:virice/src/services/cameraService.dart';
import 'package:virice/src/services/tensorflowService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:virice/generated/locale_keys.g.dart';
import 'package:virice/src/utilities/diseaseDetail.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription cameraDescription;
  const CameraPage({Key? key, required this.cameraDescription})
      : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TensorflowService _tensorflowService = TensorflowService();
  CameraService _cameraService = CameraService();
  bool isCameraStop = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _animationDialogController;
  late Animation<double> _dialogAnimation;
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
      Stopwatch stopwatch = Stopwatch()..start();
      print(">>>>>>>>>>>>>>>>>>>>>>>camera: ${stopwatch.elapsed}");
      setState(() {});
      _animationDialogController =
          AnimationController(vsync: this, duration: Duration(seconds: 1));
      _dialogAnimation = CurvedAnimation(
          parent: _animationDialogController, curve: Curves.elasticInOut);
      checkStream();
    } catch (e) {
      print("Error here $e");
    }
  }

  checkStream() {
    if (_tensorflowService.isClosedStream()) {
      _tensorflowService.createNewstream();
      _cameraService.resumeCamera();
      subscription();
    } else {
      subscription();
    }
  }

  subscription() {
    _tensorflowService.classiferController.listen((indexLabel) {
      if (indexLabel == 4) {
        print(">>>>>>>>>>>>>>This object isn't a rice ");
        _cameraService.pauseCamera();
        _animationDialogController.forward();
        _showDialog(
            content: LocaleKeys.predictedResult_isntRice.tr(),
            imgPath: "assets/img/error.png",
            children: [
              _dialogButton(Colors.green, onPressTryButton,
                  LocaleKeys.tryAgain.tr(), Colors.transparent),
              _dialogButton(Colors.red, onPressExitButton, LocaleKeys.exit.tr(),
                  Colors.red)
            ]);
      } else {
        print(">>>>>>>>>>>>>This object is a rice");
        _cameraService.pauseCamera();
        _animationDialogController.forward();
        String diseaseName = DiseaseDetail.getName(indexLabel);
        _showDialog(
            content: LocaleKeys.predictedResult_isRice
                .tr(namedArgs: {"name": diseaseName}),
            imgPath: "assets/img/complete.png",
            children: [
              _dialogButton(Colors.white, () {
                onPressPredictionButton(indexLabel);
              }, LocaleKeys.detail.tr(), Theme.of(context).primaryColor),
              _dialogButton(Theme.of(context).primaryColor, onPressTryButton,
                  LocaleKeys.tryAgain.tr(), Colors.transparent)
            ]);
      }
    });
  }

  stopService() async {
    if (!isCameraStop) {
      await _cameraService.stopDetection();
    }
    _tensorflowService.stopPrediction();
    print(">>>>>>>>Stop");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    _animationDialogController.dispose();
    stopService();
    super.dispose();
    print(">>>>>>>>>dispose");
  }

  bool _isTryButton(Color color) => color == Colors.green;
///////////////////////////////////////
  /// handle dialog button
  void onPressTryButton() {
    _animationDialogController.reverse();
    _cameraService.resumeCamera();
    Timer(const Duration(milliseconds: 800), () {
      Navigator.of(context).pop();
    });
  }

  void onPressExitButton() {
    Navigator.popUntil(
        context, (route) => route.settings.name == RouteName.HOME_PAGE);
  }

  void onPressPredictionButton(indexLabel) async {
    // Navigate to result screen
    _animationDialogController.reverse();
    _cameraService.stopDetection();
    isCameraStop = true;
    EasyLoading.instance..indicatorType = EasyLoadingIndicatorType.cubeGrid;
    EasyLoading.show(status: LocaleKeys.processing.tr());
    String path = await _cameraService.takeImage();
    print(">>>>>>>>>>>>>>>>>>>>>>>>path $path");
    Navigator.of(context).pushNamed(RouteName.RESULT_PAGE,
        arguments: <String, String>{
          "file": path,
          "index": indexLabel.toString()
        });
  }

///////////////////////////////////////
// override for backbutton in dialog
  Future<bool> _onWillPop() async {
    _cameraService.resumeCamera();
    print(">>>>>>>>>>resume");
    _animationDialogController.reverse();
    return await Future.delayed(Duration(milliseconds: 50), () {
      return true;
    });
  }

///////////////////////////////////////
  /// dialog button
  Widget _dialogButton(
      Color color, Function onPress, String label, Color backgroundColor) {
    bool isTryButton = _isTryButton(color);

    return OutlinedButton(
        style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(Size.fromWidth(120)),
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

  Future<void> _showDialog(
      {required String content,
      required String imgPath,
      required List<Widget> children}) {
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: ScaleTransition(
              scale: _dialogAnimation,
              child: Dialog(
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
                                LocaleKeys.predictedResult_title.tr(),
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 22),
                              child: Text(
                                content,
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [...children],
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45)),
                              child: Image.asset(imgPath)),
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cameraService.startCamera(widget.cameraDescription),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _cameraService.startDetection();
          return Stack(
              fit: StackFit.expand,
              alignment: Alignment.topCenter,
              children: [
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
                              LocaleKeys.infor.tr(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        );
                      },
                    ))
              ]);
        }
        // return Container(child: CircularProgressIndicator());
        return Text(LocaleKeys.processing.tr());
      },
    );
  }
}
