import 'package:flutter_app/presentation/resources/routes_manager/route_generator.dart';
import 'package:flutter_app/presentation/resources/other_managers/theme_manager.dart';
import 'package:flutter/material.dart';

import '../presentation/resources/routes_manager/routes.dart';

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  // named constructor
  MyApp._internal();

  int appState = 0;

  static final MyApp _instance =
      MyApp._internal(); // singleton or single instance

  factory MyApp() => _instance; // factory

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: Routes.splashRoute,
      theme: getApplicationTheme(),
    );
  }
}
