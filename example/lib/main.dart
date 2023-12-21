import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/ui.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTC.initialise();
  await FMTC.instance.rootDirectory.migrator.fromV6(urlTemplates: []);
  await FMTC.instance('mapStore').manage.createAsync();
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

  Future<void> initPlatformState() async {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenido a Geoform")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: const Text("Ir a Geoform"),
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeoPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeoPage extends StatelessWidget {
  const GeoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Geoform<MyMarker, MyMarker>(
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
          (_, geocontext) => Align(
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
                            final lat = geocontext
                                .geostate.selectedMarker?.position.latitude;
                            final lng = geocontext
                                .geostate.selectedMarker?.position.longitude;
                            return AlertDialog(
                              title: const Text('Information'),
                              content:
                                  geocontext.geostate.selectedMarker == null
                                      ? const Text("No Data")
                                      : Text(
                                          "$lat,$lng",
                                        ),
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
          (_, geocontext) => Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GeoformActionButton(
                        icon: const Icon(Icons.arrow_forward_rounded),
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
                                    geocontext.functions
                                        .funcToMove(mark.position, 18);
                                    await Future.delayed(
                                            const Duration(seconds: 1))
                                        .then((value) =>
                                            Navigator.pop<void>(context));
                                    geocontext.functions
                                        .funcToSelectMarker(mark);
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
                      const SizedBox(height: 8),
                      GeoformActionButton(
                        icon: const Icon(Icons.map),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('Current Map Position'),
                              content: Text(
                                  "${geocontext.currentMapPosition.latitude}, ${geocontext.currentMapPosition.longitude}"),
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
          geoformcontext,
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
                    prefixText: geoformcontext
                        .geostate.selectedMarker!.position.latitude
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
