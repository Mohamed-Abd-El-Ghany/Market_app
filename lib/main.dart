import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:test2/presentation/resources/langauge_manager.dart';
import 'app/app.dart';
import 'app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initAppModule();
  runApp(
    EasyLocalization(
      supportedLocales: const [arabicLocal, englishLocal],
      path: assetPathLocalisations,
      child: Phoenix(
        child: MyApp(),
      ),
    ),
  );
}
