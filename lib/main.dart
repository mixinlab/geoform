import 'package:flutter/material.dart';
import 'package:geoformflutter/geoform/user.dart';
import 'package:geoformflutter/geoform_widget/geoform_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Test',
      // themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: GeoFormWidget(
        name: "Rociados Pendientes",
        form: const Text("form"),
        userInformation: UserInformation(
          id: "1",
          name: "Bregy Malpartida",
        ),
      ),
    );
  }
}
