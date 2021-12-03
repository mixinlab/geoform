import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
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

class GeoFormMapWidget extends HookWidget {
  final MapController mapController = MapController();
  final String name;
  final Widget form;
  final UserInformation user;

  List<GeoFormFixedPoint>? fixedPoints;

  GeoFormMapWidget({
    Key? key,
    required this.name,
    required this.form,
    required this.user,
    this.fixedPoints,
  }) : super(key: key);

  void _animatedMapMove(
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
        // animationController.reset();
      }
    });

    animationController.forward();
  }

  StreamSubscription? subscription;

  @override
  Widget build(BuildContext context) {
    final userPosition = useState(Position.fromMap({
      "latitude": -12.04589,
      "longitude": -77.019346,
    }));

    final selectedPosition = useState(userPosition.value);

    final mapAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 820),
    );

    final manualMode = useState(false);

    useEffect(() {
      // logger.d(manualMode.value);
      if (manualMode.value) {
        subscription = mapController.mapEventStream.listen((event) {
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

    return Column(
      children: [
        // const Text("Hello World"),
        Expanded(
          // constraints: const BoxConstraints(maxHeight: 550.0),
          // width: 200.0,
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  // onPositionChanged: (position, x) =>
                  //     logger.d(position.center, x),
                  center: latLngFromPosition(userPosition.value),
                  zoom: 12.0,
                  maxZoom: 18,
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