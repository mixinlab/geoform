import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geoform/view/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/animation/animation.dart';
import 'package:geoform/animation/centroid.dart';
import 'package:geoform/bottom/bottom.dart';
import 'package:geoform/flutter_map_fast_markers/flutter_map_fast_markers.dart';
import 'package:geoform/geoform.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/ui.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
    );
  }
}

class GeoformView<T, U extends GeoformMarkerDatum> extends StatefulWidget {
  const GeoformView({
    Key? key,
    required this.formBuilder,
    required this.title,
    required this.markerBuilder,
    this.markerDrawerBuilder,
    this.records,
    this.markers,
    this.initialPosition,
    this.initialZoom,
    this.onRecordSelected,
    this.onMarkerSelected,
    this.registerOnlyWithMarker = false,
    this.followUserPositionAtStart = true,
  }) : super(key: key);

  final GeoformFormBuilder<U> formBuilder;
  final bool followUserPositionAtStart;
  final bool registerOnlyWithMarker;
  final String title;

  final GeoformMarkerBuilder<U>? markerBuilder;
  final void Function(U marker)? onMarkerSelected;

  final Future<List<T>>? records;
  final List<U>? markers;
  final LatLng? initialPosition;
  final double? initialZoom;

  final GeoformMarkerDrawerBuilder<U>? markerDrawerBuilder;

  final void Function(T record)? onRecordSelected;

  @override
  State<GeoformView> createState() => _GeoformViewState<T, U>();
}

class _GeoformViewState<T, U extends GeoformMarkerDatum>
    extends State<GeoformView> with SingleTickerProviderStateMixin {
  MapController mapController = MapController();
  LatLng mapPosition = LatLng(0, 0);
  List<FastMarker> _markers = [];
  String? serviceError;
  U? _selectedMarker;

  LatLng? _currentLatLng;

  final _tapStreamController = StreamController<TapPosition>();

  late StreamSubscription<MapEvent> mapEventSubscription;
  late AnimationController animationController;
  late StreamSubscription _locationSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLocationService();
    });

    mapEventSubscription = mapController.mapEventStream.listen((event) {
      setState(() {
        mapPosition = LatLng(event.center.latitude, event.center.longitude);
      });
    });

    mapEventSubscription.pause();

    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    setState(() {
      _markers = widget.markers
              ?.map<FastMarker>(_makerBuilderOrMarkerDrawer)
              .toList() ??
          [];
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    _locationSubscription.cancel();
    mapEventSubscription.cancel();
    super.dispose();
  }

  GeoformMarkerBuilder get _makerBuilderOrMarkerDrawer {
    if (widget.markerDrawerBuilder != null) {
      return defaultMarkerBuilder(
        customDraw: widget.markerDrawerBuilder,
        onTap: (datum) {
          setState(() {
            _selectedMarker = datum as U;
            widget.onMarkerSelected?.call(datum);
          });
        },
      );
    }
    return widget.markerBuilder ??
        defaultMarkerBuilder(
          onTap: (datum) {
            setState(() {
              _selectedMarker = datum as U;
              widget.onMarkerSelected?.call(datum);
            });
          },
        );
  }

  Future<void> initLocationService() async {
    final locationData = await determinePosition();
    if (locationData != null) {
      setState(() {
        _currentLatLng = LatLng(locationData.latitude, locationData.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    // if (_userLocation != null) {
    //   _currentLatLng =
    //       LatLng(_userLocation!.latitude!, _userLocation!.longitude!);
    // }

    final markers = <Marker>[
      Marker(
        width: 18,
        height: 18,
        point: _currentLatLng ?? LatLng(0, 0),
        builder: (ctx) => const DefaultLocationMarker(),
      ),
    ];

    // listener: (context, state) {
    //     if (state.manual) {
    //       mapEventSubscription.resume();
    //     } else {
    //       mapEventSubscription.pause();
    //     }
    //   },

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  onTap: (tapPosition, point) =>
                      _tapStreamController.add(tapPosition),
                  plugins: [FastMarkersPlugin()],
                  center: widget.initialPosition ?? LatLng(50, 50),
                  zoom: widget.initialZoom ?? 12,
                  maxZoom: 18.2,
                  minZoom: 4,
                  interactiveFlags: InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchMove,
                ),
                layers: [
                  FastMarkersLayerOptions(
                    markers: _markers,
                    tapStream: _tapStreamController,
                  ),
                  MarkerLayerOptions(
                    markers: markers,
                  ),
                  CircleLayerOptions()
                ],
                children: <Widget>[
                  TileLayerWidget(
                    options: TileLayerOptions(
                      urlTemplate:
                          'https://api.maptiler.com/maps/voyager/{z}/{x}/{y}@2x.png'
                          '?key=OvCbZy2nzfWql0vtrkbj',
                      //subdomains: ['a', 'b', 'c'],
                      tileProvider: const CachedTileProvider(),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      GeoformActionButton(
                        icon: Icon(Icons.ads_click_rounded),
                        // onPressed: () => context
                        //     .read<GeoformBloc>()
                        //     .add(ManualChanged(manual: !state.manual)),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GeoformActionButton(
                        onPressed: () {
                          animatedMapMove(
                            mapController,
                            animationController,
                            LatLng(
                              0, 0,
                              // _userLocation!.latitude!,
                              // _userLocation!.longitude!,
                            ),
                            18,
                          );
                          print(mapPosition);
                          print(_currentLatLng);
                        },
                        icon: const Icon(Icons.gps_fixed),
                      ),
                      const SizedBox(height: 8),
                      GeoformActionButton(
                        onPressed: _markers.isEmpty
                            ? null
                            : () {
                                animatedMapMove(
                                  mapController,
                                  animationController,
                                  getCentroid(markers: _markers),
                                  18,
                                );
                                print(mapPosition);
                                print(_currentLatLng);
                              },
                        icon: const Icon(Icons.circle_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              // if (state.manual)
              //   const Center(
              //     child: Icon(
              //       Icons.add,
              //       color: Colors.pink,
              //       size: 42,
              //     ),
              //   )
              // else
              //   _selectedMarker == null
              //       ? const SizedBox.shrink()
              //       : GeoformMarkerOverlay(
              //           mapController: mapController,
              //           selectedMarker: _selectedMarker,
              //           onTapOutside: () => setState(() {
              //             _selectedMarker = null;
              //           }),
              //         )
            ],
          ),
        ),
        Material(
          elevation: 8,
          child: GeoformBottomInterface<U>(
            currentPosition: _currentLatLng ?? LatLng(0, 0),
            selectedMarker: _selectedMarker,
            onPressed: !widget.registerOnlyWithMarker || _selectedMarker != null
                ? () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.formBuilder(
                          context,
                          GeoformContext(
                            currentPosition: _currentLatLng ?? LatLng(0, 0),
                            selectedMarker: _selectedMarker,
                          ),
                        ),
                      ),
                    )
                : null,
            registerOnlyWithMarker: widget.registerOnlyWithMarker,
            title: widget.title,
          ),
        ),
      ],
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title: $value',
      style: GoogleFonts.openSans(
        fontSize: 14,
        color: Colors.grey,
        // fontWeight: FontWeight.bold,
      ),
    );
  }
}
