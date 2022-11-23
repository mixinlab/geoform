import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geoform/geoform.dart';

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

  // final tileLayerOptions = TileLayerOptions(
  //   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  //   subdomains: ['a', 'b', 'c'],
  //   tileProvider: const CachedTileProvider(),
  // );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Geoform(
          title: "Geoform",
          registerWithManualSelection: true,
          formBuilder: (BuildContext context, GeoformContext geoformContext) {
            final mapPosition = geoformContext.currentMapPosition;
            final userPosition = geoformContext.currentUserPosition;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Geoform"),
              ),
              body: Center(
                child: Column(
                  children: [
                    Text(
                        'Map Position: ${mapPosition.latitude}, ${mapPosition.longitude}'),
                    Text(
                        'User Position: ${userPosition.latitude}, ${userPosition.longitude}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
