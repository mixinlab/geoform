import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/bottom/bottom.dart';
import 'package:geoform/bloc/geoform_bloc.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_polygon_layer.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/view.dart';

class GeoformContext {
  GeoformContext({
    required this.currentUserPosition,
    required this.currentMapPosition,
    this.selectedMarker,
    this.extra,
    this.actionText,
  });

  final LatLng currentUserPosition;
  final LatLng currentMapPosition;
  final GeoformMarkerDatum? selectedMarker;
  final Map<String, dynamic>? extra;

  final String? actionText;
}

typedef GeoformFormBuilder<U extends GeoformMarkerDatum> = Widget Function(
  BuildContext context,
  GeoformContext geoformContext,
);

typedef GeoformActionsBuilder<U extends GeoformMarkerDatum> = Widget Function(
  BuildContext context,
  GeoformState<U> geostate,
  void Function(U?) funcToSelectMarker,
  void Function(LatLng, double) funcToMove,
  void Function(bool) funcToChangeManual,
  void Function(List<U>) funcToUpdateMarkers,
  void Function(List<FastPolygon>) funcToUpdatePolygons,
  void Function(List<CircleMarker>) funcToUpdateCircles,
);

class Geoform<T, U extends GeoformMarkerDatum> extends StatefulWidget {
  const Geoform({
    Key? key,
    required this.formBuilder,
    required this.title,
    this.records,
    this.markers,
    this.markerBuilder,
    this.initialPosition,
    this.initialZoom,
    this.markerDrawerBuilder,
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
    this.polygonsToDraw = const [],
    this.circlesToDraw = const [],
    this.region,
    this.regionName,
    this.customTileProvider,
    this.mapProvider = MapProvider.openStreetMap,
    this.urlTemplate,
    this.setManualModeOnAction = false,
  }) : super(key: key);

  final String title;
  final GeoformFormBuilder<U> formBuilder;
  final bool registerOnlyWithMarker;
  final bool registerWithManualSelection;
  final bool followUserPositionAtStart;

  final GeoformMarkerBuilder<U>? markerBuilder;
  final GeoformMarkerDrawerBuilder<U>? markerDrawerBuilder;
  final void Function(U marker)? onMarkerSelected;

  final Future<List<T>>? records;
  final List<U>? markers;
  final void Function(T record)? onRecordSelected;

  final LatLng? initialPosition;
  final double? initialZoom;

  final GeoformBottomDisplayBuilder? bottomInformationBuilder;
  final GeoformBottomActionsBuilder? bottomActionsBuilder;
  final GeoformBottomInterface? bottomInterface;
  final void Function(BuildContext, GeoformContext)? onRegisterPressed;

  // Functions to update pos and zoom
  final void Function(LatLng?)? updatePosition;
  final void Function(double?)? updateZoom;

  final List<GeoformActionsBuilder<U>> widgetsOnSelectedMarker;
  final List<GeoformActionsBuilder<U>> additionalActionWidgets;
  final void Function()? updateThenForm;

  final List<FastPolygon> polygonsToDraw;
  final List<CircleMarker> circlesToDraw;

  final DownloadableRegion? region;
  final String? regionName;

  final Widget? customTileProvider;
  final MapProvider mapProvider;
  final String? urlTemplate;

  final bool setManualModeOnAction;

  @override
  State<Geoform<T, U>> createState() => _GeoformState<T, U>();
}

class _GeoformState<T, U extends GeoformMarkerDatum>
    extends State<Geoform<T, U>> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeoformBloc<U>(
        regionName: widget.regionName,
        mapProvider: widget.mapProvider,
        markers: widget.markers,
        polygonsToDraw: widget.polygonsToDraw,
        circlesToDraw: widget.circlesToDraw,
      )
        ..add(AddRegion(region: widget.region))
        ..add(const InitLocationService()),
      child: GeoformView<T, U>(
        formBuilder: widget.formBuilder,
        title: widget.title,
        initialPosition: widget.initialPosition,
        initialZoom: widget.initialZoom,
        followUserPositionAtStart: widget.followUserPositionAtStart,
        markerBuilder: widget.markerBuilder,
        records: widget.records,
        markerDrawer: widget.markerDrawerBuilder,
        onRecordSelected: widget.onRecordSelected,
        onMarkerSelected: widget.onMarkerSelected,
        registerOnlyWithMarker: widget.registerOnlyWithMarker,
        registerWithManualSelection: widget.registerWithManualSelection,
        bottomInformationBuilder: widget.bottomInformationBuilder,
        bottomActionsBuilder: widget.bottomActionsBuilder,
        bottomInterface: widget.bottomInterface,
        onRegisterPressed: widget.onRegisterPressed,
        updatePosition: widget.updatePosition,
        updateZoom: widget.updateZoom,
        widgetsOnSelectedMarker: widget.widgetsOnSelectedMarker,
        additionalActionWidgets: widget.additionalActionWidgets,
        updateThenForm: widget.updateThenForm,
        customTileProvider: widget.customTileProvider,
        urlTemplate: widget.urlTemplate ??
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        setManualModeOnAction: widget.setManualModeOnAction,
      ),
    );
  }
}
