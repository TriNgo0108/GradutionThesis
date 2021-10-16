import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:virice/src/pages/homePage.dart';
import 'package:virice/src/routes/Routes.dart';
import 'package:easy_localization/easy_localization.dart';

class ViRice extends StatelessWidget {
  const ViRice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: "ViRice",
      home: HomePage(),
      theme: ThemeData(
          primaryColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white, size: 20),
          textTheme: TextTheme(
              headline1: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              headline2: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
              headline3: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              headline4: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 18)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(secondary: Color.fromRGBO(204, 204, 204, 0.9))),
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: EasyLoading.init(),
    );
  }
}
