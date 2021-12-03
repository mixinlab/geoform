import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geoformflutter/geocore.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/geolocation.dart';
import 'package:geoformflutter/geoform/logger.dart';
import 'package:geoformflutter/geoform/user.dart';
import 'package:geoformflutter/geoform/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
    );
  }
}

String geoPoints({
  int? limit = 10,
  String? baseURL = "https://geocore.innovalab.minsky.cc/api/v1",
  String? group = "ee73a646-0066-4f4a-8ee9-358e77ebba7f",
}) =>
    '$baseURL/group/$group?limit=$limit';

class GeoFormMapWidget extends HookWidget {
  final String name;
  final Widget form;
  final UserInformation user;

  // List<GeoFormFixedPoint>? fixedPoints;
  StreamSubscription? subscription;

  GeoFormMapWidget({
    Key? key,
    required this.name,
    required this.form,
    required this.user,
    // this.fixedPoints,
  }) : super(key: key);

  void _animatedMapMove(
    MapController mapController,
    AnimationController animationController,
    LatLng destLocation,
    double destZoom,
  ) {
    final _latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: destLocation.latitude,
    );

    final _lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: destLocation.longitude,
    );

    final _zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: destZoom,
    );

    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );

    animationController.reset();

    animationController.addListener(() {
      mapController.move(
          LatLng(
            _latTween.evaluate(animation),
            _lngTween.evaluate(animation),
          ),
          _zoomTween.evaluate(animation));
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // animationController.removeListener(() {});
        // animationController.dispose();
        // animationController.reset();
      } else if (status == AnimationStatus.dismissed) {
        // animationController.removeListener(mapMove);
        // animationController.reset();
      }
    });

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = useState(Position.fromMap({
      "latitude": -12.04589,
      "longitude": -77.019346,
    }));

    final selectedPosition = useState(userPosition.value);

    final selectedFixedPoint = useState<GeoFormFixedPoint?>(null);

    final mapAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 820),
    );

    final mapController = useState(MapController());

    final manualMode = useState(false);

// =============================
    final points = useState<List<GeoFormFixedPoint>?>([]);

    useEffect(() {
      Dio().get<List<dynamic>>(geoPoints(limit: 1000)).then((result) {
        points.value = result.data
            ?.map((e) => GeoPoint.fromJson(e))
            .map(
              (e) => GeoFormFixedPoint(
                latLng: LatLng(
                  e.lat ?? 0.0,
                  e.lng ?? 0.0,
                ),
                metadata: {
                  "id": e.id,
                  "unicode": e.unicode,
                },
              ),
            )
            .toList();
      });
    }, []);

    // logger.d(points.value);

// =============================

    useEffect(() {
      logger.d(manualMode.value);
      if (manualMode.value) {
        subscription = mapController.value.mapEventStream.listen((event) {
          // logger.d(event.center);
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
            _animatedMapMove(
              mapController.value,
              mapAnimationController,
              latLngFromPosition(userPosition.value),
              16,
            );
          })
          .catchError((error) => logger.e(error))
          .whenComplete(() {
            watchUserPosition()
                .then(
                  (stream) => stream.listen(
                    (value) => userPosition.value = value,
                    onError: (error) => logger.e(error),
                  ),
                )
                .catchError((error) => logger.e(error));
          });
    }, []);

    useEffect(() {
      logger.d(selectedFixedPoint.value?.latLng);
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
    }, [selectedFixedPoint.value]);

    return Column(
      children: [
        // const Text("Hello World"),
        Expanded(
          // constraints: const BoxConstraints(maxHeight: 550.0),
          // width: 200.0,
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
                  TileLayerWidget(
                    options: TileLayerOptions(
                      urlTemplate:
                          "https://api.maptiler.com/maps/voyager/{z}/{x}/{y}@2x.png?key=OvCbZy2nzfWql0vtrkbj",
                      // urlTemplate:
                      //     "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      // subdomains: ['a', 'b', 'c'],
                      tileProvider: const CachedTileProvider(),
                      // attributionBuilder: (_) {
                      //   return const Padding(
                      //     padding: EdgeInsets.all(4.0),
                      //     child: Text("© OpenStreetMap contributors"),
                      //   );
                      // },
                    ),
                  ),
                  LocationMarkerLayerWidget(
                    options: LocationMarkerLayerOptions(
                      showAccuracyCircle: true,
                      showHeadingSector: false,
                    ),
                  ),
                  // GeoFormStaticLayer(fixedPoint: fixedPoint)
                  MarkerLayerWidget(
                      options: MarkerLayerOptions(
                    markers: points.value
                            ?.map(
                              (e) => Marker(
                                point: e.latLng,
                                builder: (context) => GestureDetector(
                                  onTap: () => selectedFixedPoint.value = e,
                                  child: Icon(
                                    Icons.circle_rounded,
                                    color: selectedFixedPoint
                                                .value?.metadata?["id"] ==
                                            e.metadata?["id"]
                                        ? Colors.indigo
                                        : Colors.amber,
                                    size: selectedFixedPoint
                                                .value?.metadata?["id"] ==
                                            e.metadata?["id"]
                                        ? 20.0
                                        : 16.0,
                                  ),
                                ),
                              ),
                            )
                            .toList() ??
                        [],
                  )),
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
                          _animatedMapMove(
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
                            style: GoogleFonts.openSans(
                              fontSize: 16.0,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Registra ${name}",
                            style: GoogleFonts.openSans(
                              fontSize: 20.0,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Image(
                      image: AssetImage('assets/contract.png'),
                      height: 48.0,
                      width: 48.0,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Latitude: ${selectedPosition.value.latitude}",
                      style: GoogleFonts.openSans(
                        fontSize: 14.0,
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Longitude: ${selectedPosition.value.longitude}",
                      style: GoogleFonts.openSans(
                        fontSize: 14.0,
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Accuracy: ${selectedPosition.value.accuracy.toStringAsFixed(2)}",
                      style: GoogleFonts.openSans(
                        fontSize: 14.0,
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: ButtonBar(
                  // buttonTextTheme: ButtonTextTheme.primary,
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        manualMode.value ? Icons.close : Icons.add,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child: Text(
                          "Anotar",
                          style: GoogleFonts.openSans(
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
                      // style: ButtonStyle(
                      //   shadowColor: Colors.blue,
                      // ),
                      style: manualMode.value
                          ? ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.pink),
                            )
                          : null,
                      autofocus: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          "Registrar",
                          style: GoogleFonts.openSans(
                            fontSize: 18.0,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onPressed: () {},
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
