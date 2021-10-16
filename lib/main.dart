import 'package:flutter/material.dart';
import 'package:virice/src/app.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      child: ViRice(),
      supportedLocales: [Locale("en"), Locale("vi")],
      path: 'assets/translations'));
}
