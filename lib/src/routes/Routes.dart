import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:virice/src/pages/cameraPage.dart';
import 'package:virice/src/pages/homePage.dart';
import 'package:virice/src/pages/resultPage.dart';
import 'package:virice/src/routes/routeName.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case RouteName.HOME_PAGE:
        return MaterialPageRoute(builder: (_) => HomePage());
      case RouteName.RESULT_PAGE:
        // Validation of correct data type
        if ((args as Map)["file"] is String || args["bytes"] is Uint8List) {
          return MaterialPageRoute(
            builder: (_) => ResultPage(
              file: args['file'] != null ? args["file"] : args["bytes"],
              index: args["index"],
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case RouteName.CAMERA_PAGE:
        return MaterialPageRoute(
            builder: (_) =>
                CameraPage(cameraDescription: args as CameraDescription));

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Không tìm thấy"),
        ),
        body: Center(
          child: Text("Không tìm thấy nội dung yêu cầu"),
        ),
      );
    });
  }
}
