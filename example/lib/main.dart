import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geoform/bloc/geoform_bloc.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/ui.dart';
import 'package:latlong2/latlong.dart';
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
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Geoform(
        title: "Geoform",
        registerOnlyWithMarker: true,
        registerWithManualSelection: true,
        initialPosition: LatLng(-16.40904025, -71.509028501),
        initialZoom: 18,
        markers: [MyMarker(position: LatLng(-16.40904025, -71.509028501))],
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
        widgetsOnSelectedMarker: [
          (marker) => Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GeoformActionButton(
                        icon: const Icon(Icons.map_outlined),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('Information'),
                              content: const Text("Data"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop<void>(context),
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
        additionalActionWidgets: [
          (GeoformState state, void Function(MyMarker) selectDatum,
                  void Function(LatLng, double) move, _) =>
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GeoformActionButton(
                        icon: const Icon(Icons.map_outlined),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('Additional Function'),
                              content: const Text("Go to point"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    final mark = MyMarker(
                                      position: LatLng(
                                        -16.40904025,
                                        -71.509028501,
                                      ),
                                    );
                                    move(mark.position, 18);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    selectDatum(mark);
                                    Navigator.pop<void>(context);
                                  },
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
        followUserPositionAtStart: false,
        setManualModeOnAction: true,
        bottomActionsBuilder: (
          context,
          actionActivated,
          actionTextController,
          selectedMarker,
          onActionPressed,
          onRegisterPressed,
        ) {
          return Column(
            children: [
              if (actionActivated) ...[
                const SizedBox(height: 16),
                TextFormField(
                  autocorrect: false,
                  controller: actionTextController,
                  decoration: InputDecoration(
                    prefixText: (selectedMarker! as MyMarker)
                        .position
                        .latitude
                        .toString(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    labelText: "Editar",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white70,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    errorMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: onActionPressed,
                      style: ElevatedButton.styleFrom(
                        animationDuration: const Duration(milliseconds: 300),
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(actionActivated ? 'Cancelar' : 'Adicional'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        animationDuration: const Duration(milliseconds: 300),
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyMarker implements GeoformMarkerDatum {
  MyMarker({required this.position});

  @override
  final LatLng position;
}
