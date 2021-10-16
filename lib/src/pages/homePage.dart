import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virice/generated/locale_keys.g.dart';
import 'package:virice/src/routes/routeName.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:virice/src/services/tensorflowService.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationDialogController;
  late Animation<double> _dialogAnimation;
  TensorflowService _tensorflowService = TensorflowService();

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone
    ].request();
    final info = statuses[Permission.storage].toString();
    print('$info');
  }

  void _onCamera() async {
    final cameras = await availableCameras();
    Timer(const Duration(milliseconds: 100), () {
      Navigator.of(context)
          .pushNamed(RouteName.CAMERA_PAGE, arguments: cameras.first);
    });
  }

  void _onGallery() async {
    print("choose from gallery ");
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      EasyLoading.instance..indicatorType = EasyLoadingIndicatorType.cubeGrid;
      EasyLoading.show(status: LocaleKeys.processing.tr());
      var recognitions = await _tensorflowService.runModelonImage(image.path);
      if (recognitions != 4) {
        Navigator.of(context).pushNamed(RouteName.RESULT_PAGE,
            arguments: <String, String>{
              "file": image.path,
              "index": recognitions.toString()
            });
      } else {
        EasyLoading.dismiss();
        _animationDialogController.forward();
        _showDialog(
            content: LocaleKeys.predictedResult_isntRice.tr(),
            imgPath: "assets/img/error.png",
            child: OutlinedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Colors.green)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)))),
                onPressed: () {
                  _animationDialogController.reverse();
                  Timer(const Duration(milliseconds: 800), () {
                    Navigator.of(context).pop();
                  });
                },
                child: Text(
                  LocaleKeys.tryAgain.tr(),
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )));
      }
    }
  }

  Future<bool> _onWillPop() async {
    _animationDialogController.reverse();
    return await Future.delayed(Duration(milliseconds: 800), () {
      return true;
    });
  }

  Future<void> _showDialog(
      {required String content,
      required String imgPath,
      required Widget child}) {
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
                            Center(
                              child: child,
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

  void _showModalBottomSheet() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (_) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 150,
              child: (Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onGallery();
                        },
                        icon: FaIcon(FontAwesomeIcons.fileImport),
                        label: Text(
                          LocaleKeys.fromGallery.tr(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20),
                        )),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onCamera();
                        },
                        icon: FaIcon(FontAwesomeIcons.camera),
                        label: Text(
                          LocaleKeys.fromCamera.tr(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20),
                        )),
                  )
                ],
              )),
            ),
          );
        });
  }

  loadModel() async {
    await _tensorflowService.loadModel();
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    loadModel();
    _animationDialogController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _dialogAnimation = CurvedAnimation(
        parent: _animationDialogController, curve: Curves.elasticInOut);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    context.setLocale(Locale("en"));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _tensorflowService.close();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.title).tr(),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: _showModalBottomSheet,
              child: Container(
                width: width * 0.9,
                height: height * 0.4,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.secondary,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_search_rounded,
                      size: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        LocaleKeys.description.tr(),
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: _onGallery,
                    icon: FaIcon(FontAwesomeIcons.fileImport),
                    label: Text(
                      LocaleKeys.fromGallery.tr(),
                      style: Theme.of(context).textTheme.headline2,
                    )),
                ElevatedButton.icon(
                    onPressed: _onCamera,
                    icon: FaIcon(FontAwesomeIcons.camera),
                    label: Text(
                      LocaleKeys.fromCamera.tr(),
                      style: Theme.of(context).textTheme.headline2,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
