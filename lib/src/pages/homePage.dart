import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virice/src/routes/routeName.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final info = statuses[Permission.storage].toString();
    print('$info');
  }

  void _loadModel() async {
    String? res = await Tflite.loadModel(
        model: "assets/res/model.tflite",
        labels: "assets/res/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
    print(res ?? "aaaaa");
  }

  void _onCamera() async {
    final cameras = await availableCameras();
    // print("choose from camera");
    // XFile? image = await _picker.pickImage(source: ImageSource.camera);
    // if (image != null) {
    //   // Navigator.of(context)
    //   //     .pushNamed(RouteName.RESUL_TPAGE, arguments: image.path);
    //   EasyLoading.instance..indicatorType = EasyLoadingIndicatorType.cubeGrid;
    //   EasyLoading.show(status: "Đang xử lý");

    //   var recognitions = await Tflite.runModelOnImage(
    //       path: image.path, // required
    //       imageMean: 0.0, // defaults to 117.0
    //       imageStd: 255.0, // defaults to 1.0
    //       numResults: 2, // defaults to 5
    //       threshold: 0.2, // defaults to 0.1
    //       asynch: true // defaults to true
    //       );
    //   if (recognitions != null) {
    //     print(recognitions[0]["index"]);
    //     Navigator.of(context).pushNamed(RouteName.RESULT_PAGE,
    //         arguments: <String, String>{
    //           "filePath": image.path,
    //           "index": recognitions[0]["index"].toString()
    //         });
    //   }
    // }
    Navigator.of(context).pushNamed(RouteName.CAMERA_PAGE,arguments: cameras.first);
  }

  void _onGallery() async {
    print("choose from gallery ");
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      EasyLoading.instance..indicatorType = EasyLoadingIndicatorType.cubeGrid;
      EasyLoading.show(status: "Đang xử lý");
      var recognitions = await Tflite.runModelOnImage(
          path: image.path, // required
          imageMean: 0.0, // defaults to 117.0
          imageStd: 255.0, // defaults to 1.0
          numResults: 2, // defaults to 5
          threshold: 0.2, // defaults to 0.1
          asynch: true // defaults to true
          );
      if (recognitions != null) {
        print(recognitions[0]["index"]);
        Navigator.of(context).pushNamed(RouteName.RESULT_PAGE,
            arguments: <String, String>{
              "file": image.path,
              "index": recognitions[0]["index"].toString()
            });
      }
    }
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
                          "Từ thư viện",
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
                          "Từ camera",
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

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Dự đoán bệnh"),
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
                    color: Theme.of(context).accentColor, // remember fix this deprecate
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
                        "Chọn ảnh từ thư viện hoặc chụp ảnh để dự đoán",
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
                      "Từ thư viện",
                      style: Theme.of(context).textTheme.headline2,
                    )),
                ElevatedButton.icon(
                    onPressed: _onCamera,
                    icon: FaIcon(FontAwesomeIcons.camera),
                    label: Text(
                      "Từ camera",
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
