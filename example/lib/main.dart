import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geoform/map/map.dart';
import 'package:geoform/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  final tileLayerOptions = TileLayerOptions(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c'],
    tileProvider: const CachedTileProvider(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: GeoFormMapWidget(
          mapLayerOptions: tileLayerOptions,
          name: "Inspecciones",
          form: const Text("Form"),
          formWrapperOptions: FormWrapperOptions(title: "Nuevo Registro"),
          user: UserInformation(id: "01", name: "User01"),
        ),
      ),
    );
  }
}
