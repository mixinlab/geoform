import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geoform/animation/animation.dart';
import 'package:geoform/animation/centroid.dart';
import 'package:geoform/bottom/bottom.dart';
import 'package:geoform/flutter_map_fast_markers/flutter_map_fast_markers.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_polygon_layer.dart';
import 'package:geoform/geoform.dart';
import 'package:geoform/bloc/geoform_bloc.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/overlay.dart';
import 'package:geoform/view/ui.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vectortile;

class GeoformView<T, U extends GeoformMarkerDatum> extends StatefulWidget {
  const GeoformView({
    Key? key,
    required this.formBuilder,
    required this.title,
    required this.markerBuilder,
    this.markerDrawer,
    this.records,
    this.markers,
    this.initialPosition,
    this.initialZoom,
    this.onRecordSelected,
    this.onMarkerSelected,
    this.registerOnlyWithMarker = false,
    this.followUserPositionAtStart = true,
    this.registerWithManualSelection = false,
    this.bottomInformationBuilder,
    this.bottomActionsBuilder,
    this.bottomInterface,
    this.updatePosition,
    this.updateZoom,
    this.widgetsOnSelectedMarker = const [],
    this.updateThenForm,
    this.polygonsToDraw = const [],
    this.circlesToDraw = const [],
    this.customTileProvider,
    this.urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  }) : super(key: key);

  final GeoformFormBuilder<U> formBuilder;
  final bool followUserPositionAtStart;
  final bool registerOnlyWithMarker;
  final bool registerWithManualSelection;
  final String title;

  final GeoformMarkerBuilder<U>? markerBuilder;
  final void Function(U marker)? onMarkerSelected;

  final Future<List<T>>? records;
  final List<U>? markers;
  final LatLng? initialPosition;
  final double? initialZoom;

  final GeoformMarkerDrawerBuilder<U>? markerDrawer;

  final void Function(T record)? onRecordSelected;

  final GeoformBottomDisplayBuilder? bottomInformationBuilder;
  final GeoformBottomActionsBuilder? bottomActionsBuilder;
  final GeoformBottomInterface? bottomInterface;

  // Functions to update pos and zoom
  final void Function(LatLng?)? updatePosition;
  final void Function(double?)? updateZoom;

  final List<Widget Function(U?)> widgetsOnSelectedMarker;
  final void Function()? updateThenForm;

  final List<FastPolygon> polygonsToDraw;
  final List<CircleMarker> circlesToDraw;

  final Widget? customTileProvider;
  final String urlTemplate;

  @override
  State<GeoformView> createState() => _GeoformViewState<T, U>();
}

class _GeoformViewState<T, U extends GeoformMarkerDatum>
    extends State<GeoformView> with SingleTickerProviderStateMixin {
  MapController mapController = MapController();
  LatLng _currentMapPosition = LatLng(0, 0);
  late StreamSubscription<MapEvent> mapEventSubscription;
  late AnimationController animationController;

  List<FastMarker> _markers = [];
  final _tapStreamController = StreamController<TapPosition>();

  bool _isActionActivated = false;

  LocationData? _userLocation;
  String? serviceError;

  U? _selectedMarker;

  late StreamSubscription _locationSubscription;

  final TextEditingController actionTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLocationService();
    });

    mapEventSubscription = mapController.mapEventStream.listen((event) {
      setState(() {
        _currentMapPosition =
            LatLng(event.center.latitude, event.center.longitude);
      });
    })
      ..pause();

    animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    setState(() {
      _markers = widget.markers
              ?.map<FastMarker>(_makerBuilderOrMarkerDrawer)
              .toList() ??
          [];
    });

    // TODO(all): Catch errors;
  }

  @override
  void dispose() {
    animationController.dispose();
    _locationSubscription.cancel();
    mapEventSubscription.cancel();
    super.dispose();
  }

  GeoformMarkerBuilder get _makerBuilderOrMarkerDrawer {
    if (widget.markerDrawer != null) {
      return defaultMarkerBuilder(
        customDraw: widget.markerDrawer,
        onTap: (datum) {
          setState(() {
            if (context.read<GeoformBloc>().state.manual) {
              context
                  .read<GeoformBloc>()
                  .add(const ManualChanged(manual: false));
            }
            _selectedMarker = datum as U;
            widget.onMarkerSelected?.call(datum);
            actionTextController.clear();
          });
        },
      );
    }

    return widget.markerBuilder ??
        defaultMarkerBuilder(
          onTap: (datum) {
            setState(() {
              if (context.read<GeoformBloc>().state.manual) {
                context
                    .read<GeoformBloc>()
                    .add(const ManualChanged(manual: false));
              }
              _selectedMarker = datum as U;
              widget.onMarkerSelected?.call(datum);
              actionTextController.clear();
            });
          },
        );
  }

  Future<void> initLocationService() async {
    LocationData locationData;
    final _locationService = Location();

    try {
      final serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        final permission = await _locationService.requestPermission();
        final _permission = permission == PermissionStatus.granted;

        if (_permission) {
          locationData = await _locationService.getLocation();
          setState(() {
            _userLocation = locationData;
          });
          if (widget.followUserPositionAtStart) {
            animatedMapMove(
              mapController,
              animationController,
              LatLng(
                _userLocation?.latitude ?? 0,
                _userLocation?.longitude ?? 0,
              ),
              18,
            );
          }

          _locationSubscription =
              _locationService.onLocationChanged.listen((locationData) async {
            if (mounted) {
              setState(() {
                _userLocation = locationData;
              });
            }
          });
        }
      } else {
        final serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          await initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        serviceError = e.message;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng? _currentLatLng;

    if (_userLocation != null) {
      _currentLatLng =
          LatLng(_userLocation!.latitude!, _userLocation!.longitude!);
    }

    final markers = <Marker>[
      Marker(
        width: 18,
        height: 18,
        point: _currentLatLng ?? LatLng(0, 0),
        builder: (ctx) => const DefaultLocationMarker(),
      ),
    ];

    return BlocConsumer<GeoformBloc, GeoformState>(
      listenWhen: (previous, current) => previous.manual != current.manual,
      listener: (context, state) {
        if (state.manual) {
          mapEventSubscription.resume();
        } else {
          mapEventSubscription.pause();
        }
      },
      builder: (context, state) {
        if (state.isDownloading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CupertinoActivityIndicator(),
                const SizedBox(height: 10),
                Text(
                  'Downloading...',
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      onTap: (tapPosition, point) {
                        context.read<GeoformBloc>().add(
                              GeoformOnTap(tapPosition: tapPosition),
                            );
                      },
                      center: widget.initialPosition ?? LatLng(50, 50),
                      zoom: widget.initialZoom ?? 12,
                      maxZoom: 18.2,
                      minZoom: 4,
                      keepAlive: true,
                      interactiveFlags: InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.flingAnimation |
                          InteractiveFlag.pinchMove,
                      onPositionChanged: (position, hasGesture) {
                        final zoom = position.zoom;
                        final pos = position.center;
                        if (widget.updateZoom != null) {
                          widget.updateZoom!(zoom);
                        }
                        if (widget.updatePosition != null) {
                          widget.updatePosition!(pos);
                        }
                      },
                    ),
                    children: <Widget>[
                      baseTileProvider(),
                      CircleLayer(
                        circles: widget.circlesToDraw,
                      ),
                      FastPolygonLayer(
                        polygonCulling: true,
                        polygons: widget.polygonsToDraw,
                      ),
                      FastMarkersLayer(_markers),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  if (_selectedMarker == null) ...{
                    if (widget.registerWithManualSelection)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GeoformActionButton(
                                icon: const Icon(Icons.ads_click_rounded),
                                onPressed: () => context
                                    .read<GeoformBloc>()
                                    .add(ManualChanged(manual: !state.manual)),
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
                                    _userLocation!.latitude!,
                                    _userLocation!.longitude!,
                                  ),
                                  18,
                                );
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
                                        13,
                                      );
                                    },
                              icon: const Icon(Icons.circle_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                  },
                  if (state.manual)
                    const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.pink,
                        size: 42,
                      ),
                    )
                  else
                    _selectedMarker == null
                        ? const SizedBox.shrink()
                        : GeoformMarkerOverlay(
                            mapController: mapController,
                            selectedMarker: _selectedMarker,
                            onTapOutside: () => setState(() {
                              _selectedMarker = null;
                              _isActionActivated = false;
                            }),
                          ),
                  if (_selectedMarker != null) ...{
                    for (var item in widget.widgetsOnSelectedMarker)
                      item(_selectedMarker),
                  },
                ],
              ),
            ),
            Material(
              elevation: 8,
              child: widget.bottomInterface ??
                  GeoformBottomInterface<U>(
                    actionActivated: _isActionActivated,
                    currentPosition: _currentLatLng ?? LatLng(0, 0),
                    selectedMarker: _selectedMarker,
                    actionTextController: actionTextController,
                    onRegisterPressed:
                        (widget.registerWithManualSelection && state.manual) ||
                                (widget.registerOnlyWithMarker &&
                                    _selectedMarker != null)
                            ? () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => widget.formBuilder(
                                      context,
                                      GeoformContext(
                                        currentUserPosition:
                                            _currentLatLng ?? LatLng(0, 0),
                                        currentMapPosition: _currentMapPosition,
                                        selectedMarker: _selectedMarker,
                                        actionText: actionTextController.text,
                                      ),
                                    ),
                                  ),
                                ).then((value) {
                                  actionTextController.clear();
                                  widget.updateThenForm?.call();
                                });
                              }
                            : null,
                    onActionPressed: !widget.registerOnlyWithMarker ||
                            _selectedMarker != null
                        ? () {
                            setState(() {
                              _isActionActivated = !_isActionActivated;
                            });
                          }
                        : null,
                    registerOnlyWithMarker: widget.registerOnlyWithMarker,
                    title: widget.title,
                    informationBuilder: widget.bottomInformationBuilder,
                    actionsBuilder: widget.bottomActionsBuilder,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget baseTileProvider() {
    return BlocBuilder<GeoformBloc, GeoformState>(
      builder: (context, state) {
        if (state.mapProvider == MapProvider.openStreetMap) {
          return TileLayer(
            tileProvider: state.regionName == null
                ? null
                : FMTC.instance(state.regionName!).getTileProvider(),
            urlTemplate: widget.urlTemplate,
          );
        }
        if (state.mapProvider == MapProvider.vectorProvider) {
          return VectorTileLayer(
            theme: _mapTheme(context),
            tileProviders: TileProviders(
              {
                'openmaptiles': _cachingTileProvider(widget.urlTemplate),
              },
            ),
          );
        }
        return widget.customTileProvider ?? Container();
      },
    );
  }
}

VectorTileProvider _cachingTileProvider(String urlTemplate) {
  return MemoryCacheVectorTileProvider(
      delegate: NetworkVectorTileProvider(
          urlTemplate: urlTemplate,
          // this is the maximum zoom of the provider, not the
          // maximum of the map. vector tiles are rendered
          // to larger sizes to support higher zoom levels
          maximumZoom: 14),
      maxSizeBytes: 1024 * 1024 * 2);
}

vectortile.Theme _mapTheme(BuildContext context) {
  // maps are rendered using themes
  // to provide a dark theme do something like this:
  // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
  return vectortile.ProvidedThemes.lightTheme();
}
