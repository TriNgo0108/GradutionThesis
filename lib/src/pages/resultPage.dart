import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:virice/src/routes/routeName.dart';
import 'package:virice/src/utilities/diseaseDetail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:virice/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ResultPage extends StatefulWidget {
  final String? file;
  final String? index;
  ResultPage({Key? key, this.file, this.index}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  GlobalKey saveImage = GlobalKey();
  Widget _indexWidget(String text) {
    return (Padding(
      padding: EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline3,
      ),
    ));
  }

  Widget _contentWidget(String text) {
    return (Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline4,
        textAlign: TextAlign.justify,
      ),
    ));
  }

  void takeScreenShot() async {
    RenderRepaintBoundary boundary = saveImage.currentContext
        ?.findRenderObject() as RenderRepaintBoundary; // the key provided
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();
    ImageGallerySaver.saveImage(pngBytes!);
    print("Save image");
    Fluttertoast.showToast(
        msg: LocaleKeys.savedImage.tr(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<bool> _onWillPop() async {
    Navigator.popUntil(
        context, (route) => route.settings.name == RouteName.HOME_PAGE);
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    DiseaseDetail disease = new DiseaseDetail(int.parse(widget.index ?? "4"));
    var name = disease.getName();
    var reason = disease.getReason();
    var solution = disease.getSolution();
    IconThemeData iconThemeData = Theme.of(context).iconTheme;
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.result.tr(),
            style: Theme.of(context).textTheme.headline1,
          ),
          actions: [
            IconButton(
                onPressed: takeScreenShot,
                icon: FaIcon(FontAwesomeIcons.solidImage))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: iconThemeData.color,
            size: iconThemeData.size,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.popUntil(
                context, (route) => route.settings.name == RouteName.HOME_PAGE);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              RepaintBoundary(
                key: saveImage,
                child: Container(
                  constraints: BoxConstraints(minHeight: height * 0.87),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          width: double.infinity,
                          height: height * 0.4,
                          child: Image.file(
                            File(widget.file as String),
                            fit: BoxFit.cover,
                          )),
                      _indexWidget(LocaleKeys.diseaseName_title.tr()),
                      _contentWidget(name),
                      _indexWidget(LocaleKeys.diseaseReason_title.tr()),
                      _contentWidget(reason),
                      _indexWidget(LocaleKeys.diseaseSolution_title.tr()),
                      _contentWidget(solution)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
