import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
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
    this.onRegisterPressed,
    this.updatePosition,
    this.updateZoom,
    this.widgetsOnSelectedMarker = const [],
    this.additionalActionWidgets = const [],
    this.updateThenForm,
    this.customTileProvider,
    this.urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.setManualModeOnAction = false,
  }) : super(key: key);

  final String title;
  final bool followUserPositionAtStart;
  final bool registerOnlyWithMarker;
  final bool registerWithManualSelection;
  final bool setManualModeOnAction;

  final Widget? customTileProvider;
  final String urlTemplate;

  final GeoformFormBuilder<U> formBuilder;
  final GeoformMarkerBuilder<U>? markerBuilder;
  final GeoformMarkerDrawerBuilder<U>? markerDrawer;

  final void Function(U marker)? onMarkerSelected;
  final void Function(T record)? onRecordSelected;
  final void Function(BuildContext, GeoformContext)? onRegisterPressed;

  final Future<List<T>>? records;
  final LatLng? initialPosition;
  final double? initialZoom;

  final GeoformBottomDisplayBuilder? bottomInformationBuilder;
  final GeoformBottomActionsBuilder? bottomActionsBuilder;
  final GeoformBottomInterface? bottomInterface;

  // Functions to update pos and zoom
  final void Function(LatLng?)? updatePosition;
  final void Function(double?)? updateZoom;

  final List<GeoformActionsBuilder<U>> widgetsOnSelectedMarker;
  final List<GeoformActionsBuilder<U>> additionalActionWidgets;
  final void Function()? updateThenForm;

  @override
  State<GeoformView> createState() => _GeoformViewState<T, U>();
}

class _GeoformViewState<T, U extends GeoformMarkerDatum>
    extends State<GeoformView<T, U>> with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  late AnimationController _animationController;
  final TextEditingController actionTextController = TextEditingController();

  GeoformMarkerBuilder<U> get _makerBuilderOrMarkerDrawer =>
      widget.markerBuilder ??
      defaultMarkerBuilder(
        customDraw: widget.markerDrawer,
        onTap: _selectDatum,
      );

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _selectDatum(U? datum) {
    setState(() {
      if (datum != null) widget.onMarkerSelected?.call(datum);
      actionTextController.clear();
      context.read<GeoformBloc<U>>().add(SelectMarker(marker: datum));
    });
  }

  void _move(LatLng pos, double zoom) {
    animatedMapMove(_mapController, _animationController, pos, zoom);
  }

  void _updateMarkers(List<U> markers) =>
      context.read<GeoformBloc<U>>().add(UpdateMarkers(markers: markers));

  void _updatePolygons(List<FastPolygon> polygons) =>
      context.read<GeoformBloc<U>>().add(UpdatePolygons(polygons: polygons));

  void _updateCircles(List<CircleMarker> circles) =>
      context.read<GeoformBloc<U>>().add(UpdateCircles(circles: circles));

  void _changeManual(bool manual) =>
      context.read<GeoformBloc<U>>().add(ManualChanged(manual: manual));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeoformBloc<U>, GeoformState<U>>(
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
        final currentLatLng = state.userLocation != null
            ? LatLng(
                state.userLocation!.latitude, state.userLocation!.longitude)
            : null;
        final markers = <Marker>[
          Marker(
            width: 18,
            height: 18,
            point: currentLatLng ?? LatLng(0, 0),
            builder: (ctx) => const DefaultLocationMarker(),
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      onTap: (tapPosition, point) {
                        context.read<GeoformBloc<U>>().add(
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
                    children: [
                      baseTileProvider(),
                      CircleLayer(
                        circles: state.circlesToDraw,
                      ),
                      FastPolygonLayer(
                        polygonCulling: true,
                        polygons: state.polygonsToDraw,
                      ),
                      FastMarkersLayer<U>(
                        state.markers
                            .map<FastMarker>(_makerBuilderOrMarkerDrawer)
                            .toList(),
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  if (state.selectedMarker == null) ...{
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
                                onPressed: () => _changeManual(!state.manual),
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
                              onPressed: state.userLocation != null
                                  ? () => _move(
                                        LatLng(
                                          state.userLocation?.latitude ?? 0,
                                          state.userLocation?.longitude ?? 0,
                                        ),
                                        18,
                                      )
                                  : null,
                              icon: const Icon(Icons.gps_fixed),
                            ),
                            const SizedBox(height: 8),
                            GeoformActionButton(
                              onPressed: state.markers.isEmpty
                                  ? null
                                  : () => _move(
                                        getCentroid(markers: state.markers),
                                        13,
                                      ),
                              icon: const Icon(Icons.circle_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (var item in widget.additionalActionWidgets)
                      item(
                        context,
                        state,
                        _selectDatum,
                        _move,
                        _changeManual,
                        _updateMarkers,
                        _updatePolygons,
                        _updateCircles,
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
                    state.selectedMarker == null
                        ? const SizedBox.shrink()
                        : GeoformMarkerOverlay(
                            mapController: _mapController,
                            selectedMarker: state.selectedMarker,
                            onTapOutside: () => _selectDatum(null),
                          ),
                  if (state.selectedMarker != null) ...{
                    for (var item in widget.widgetsOnSelectedMarker)
                      item(
                        context,
                        state,
                        _selectDatum,
                        _move,
                        _changeManual,
                        _updateMarkers,
                        _updatePolygons,
                        _updateCircles,
                      ),
                  },
                ],
              ),
            ),
            Material(
              elevation: 8,
              child: widget.bottomInterface ??
                  GeoformBottomInterface<U>(
                    actionActivated: state.isActionActivated,
                    currentPosition: currentLatLng ?? LatLng(0, 0),
                    selectedMarker: state.selectedMarker,
                    actionTextController: actionTextController,
                    onRegisterPressed:
                        (widget.registerWithManualSelection && state.manual) ||
                                (widget.registerOnlyWithMarker &&
                                    state.selectedMarker != null)
                            ? () {
                                final geoContext = GeoformContext(
                                  currentUserPosition:
                                      currentLatLng ?? LatLng(0, 0),
                                  currentMapPosition: _mapController.center,
                                  selectedMarker: state.selectedMarker,
                                  actionText: actionTextController.text,
                                );
                                if (widget.onRegisterPressed != null) {
                                  widget.onRegisterPressed!.call(
                                    context,
                                    geoContext,
                                  );
                                } else {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => widget.formBuilder(
                                        context,
                                        geoContext,
                                      ),
                                    ),
                                  ).then((value) {
                                    actionTextController.clear();
                                    widget.updateThenForm?.call();
                                  });
                                }
                              }
                            : null,
                    onActionPressed: !widget.registerOnlyWithMarker ||
                            state.selectedMarker != null
                        ? () {
                            context.read<GeoformBloc<U>>().add(
                                  ChangeActivateAction(
                                    isActivated: !state.isActionActivated,
                                  ),
                                );
                            if (widget.setManualModeOnAction) {
                              _changeManual(!state.manual);
                            }
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
    return BlocBuilder<GeoformBloc<U>, GeoformState<U>>(
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
