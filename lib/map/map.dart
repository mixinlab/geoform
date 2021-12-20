import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoform/entities.dart';
import 'package:geoform/geolocation.dart';
import 'package:geoform/map/animation.dart';
import 'package:geoform/map/basic_information.dart';
import 'package:geoform/map/marker.dart';
import 'package:geoform/user.dart';
import 'package:geoform/utils.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
    );
  }
}

class GeoFormMapWidget extends HookWidget {
  final String name;
  final Widget form;
  final UserInformation user;
  final List<GeoFormFixedPoint>? points;
  final MapController? mapController;
  final Widget Function(BuildContext, GeoFormFixedPoint, bool)? markerBuilder;

  final TileLayerOptions mapLayerOptions;

  StreamSubscription? subscription;

  GeoFormMapWidget({
    Key? key,
    required this.mapLayerOptions,
    required this.name,
    required this.form,
    required this.user,
    this.points,
    this.mapController,
    this.markerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPosition = useState(Position.fromMap({
      "latitude": -12.04589,
      "longitude": -77.019346,
    }));

    final manualMode = useState(false);
    final mapController = useState(this.mapController ?? MapController());
    final selectedPosition = useState(userPosition.value);
    final selectedFixedPoint = useState<GeoFormFixedPoint?>(null);

    final mapAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 820),
    );

    useEffect(() {
      if (manualMode.value) {
        selectedFixedPoint.value = null;
        subscription = mapController.value.mapEventStream.listen((event) {
          selectedPosition.value = Position(
            longitude: event.center.longitude,
            latitude: event.center.latitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        });
      }

      if (manualMode.value == false) {
        subscription?.cancel();
      }
    }, [manualMode.value]);

    useEffect(() {
      determinePosition()
          .then((value) {
            userPosition.value = value;
            animatedMapMove(
              mapController.value,
              mapAnimationController,
              latLngFromPosition(userPosition.value),
              16,
            );
          })
          .catchError((error) => print(error))
          .whenComplete(() {
            watchUserPosition()
                .then(
                  (stream) => stream.listen(
                    (value) => userPosition.value = value,
                    onError: (error) => print(error),
                  ),
                )
                .catchError((error) => print(error));
          });
    }, []);

    useEffect(() {
      // logger.d(selectedFixedPoint.value?.latLng);
      if (selectedFixedPoint.value != null) {
        selectedPosition.value = Position(
          longitude: selectedFixedPoint.value?.latLng.longitude ?? 0.0,
          latitude: selectedFixedPoint.value?.latLng.latitude ?? 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }
    }, [selectedFixedPoint.value]);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController.value,
                options: MapOptions(
                  center: latLngFromPosition(userPosition.value),
                  zoom: 12.0,
                  maxZoom: 18,
                  minZoom: 4,
                  interactiveFlags: InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchMove,
                ),
                children: [
                  TileLayerWidget(options: mapLayerOptions),
                  LocationMarkerLayerWidget(
                    options: LocationMarkerLayerOptions(
                      showAccuracyCircle: true,
                      showHeadingSector: false,
                    ),
                  ),
                  MarkerLayerWidget(
                    options: MarkerLayerOptions(
                      markers: points
                              ?.map(
                                (e) => Marker(
                                  point: e.latLng,
                                  builder: (context) => GestureDetector(
                                    onTap: () => selectedFixedPoint.value = e,
                                    child: markerBuilder != null
                                        ? markerBuilder!(
                                            context,
                                            e,
                                            selectedFixedPoint
                                                    .value?.metadata?["id"] ==
                                                e.metadata?["id"])
                                        : DefaultMarker(
                                            isSelected: selectedFixedPoint
                                                    .value?.metadata?["id"] ==
                                                e.metadata?["id"],
                                          ),
                                  ),
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                  ),
                ],
              ),
              manualMode.value
                  ? const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.pink,
                        size: 42,
                      ),
                    )
                  : Container(),
              Align(
                // offset: const Offset(0, 100),
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        borderRadius: BorderRadius.circular(8.0),
                        // color: Colors.transparent,
                        child: Ink(
                          decoration: const ShapeDecoration(
                            // color: Colors.black,
                            // color: ,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: () {
                              selectedPosition.value = userPosition.value;
                              animatedMapMove(
                                mapController.value,
                                mapAnimationController,
                                latLngFromPosition(userPosition.value),
                                16,
                              );
                            },
                            icon: const Icon(
                              Icons.circle_outlined,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(8.0),
                          // color: Colors.transparent,
                          child: Ink(
                            decoration: const ShapeDecoration(
                              // color: Colors.black,
                              // color: ,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                selectedPosition.value = userPosition.value;
                                animatedMapMove(
                                  mapController.value,
                                  mapAnimationController,
                                  latLngFromPosition(userPosition.value),
                                  16,
                                );
                              },
                              icon: const Icon(
                                Icons.gps_fixed,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, ${user.name}!",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Registra $name",
                            style: const TextStyle(
                              fontSize: 20.0,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0.0,
                ),
                alignment: Alignment.centerLeft,
                child: BasicTextualInformation(
                  selectedPosition: selectedPosition.value,
                  metadata: selectedFixedPoint.value?.metadata,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: ButtonBar(
                  // buttonTextTheme: ButtonTextTheme.accent,

                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        manualMode.value ? Icons.close : Icons.add,
                      ),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child: Text(
                          "Anotar",
                          style: TextStyle(
                            fontSize: 16.0,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onPressed: () => manualMode.value = !manualMode.value,
                      // setState(() => currentMode = GeoFormMode.auto),
                    ),
                    ElevatedButton(
                      clipBehavior: Clip.antiAlias,
                      autofocus: true,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 60.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          "Registrar",
                          style: TextStyle(
                            fontSize: 18.0,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Nuevo Registro"),
                              ),
                              floatingActionButton:
                                  FloatingActionButton.extended(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                label: const Text(
                                  "Registrar",
                                ),
                                icon: const Icon(Icons.save),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        BasicTextualInformation(
                                          selectedPosition:
                                              selectedPosition.value,
                                          metadata: selectedFixedPoint
                                              .value?.metadata,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Row(
                                        children: [
                                          form,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      // => setState(() => _showMyDialog()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
