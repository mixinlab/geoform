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

  final List<Widget Function(BuildContext, U?)> widgetsOnSelectedMarker;
  final List<
      Widget Function(
    BuildContext,
    GeoformState,
    void Function(U),
    void Function(LatLng, double),
    List<U>?,
  )> additionalActionWidgets;
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
    extends State<Geoform<T, U>> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeoformBloc(
        regionName: widget.regionName,
        mapProvider: widget.mapProvider,
        initialPosition: widget.initialPosition,
        animationController: AnimationController(
          duration: const Duration(seconds: 1),
          vsync: this,
        ),
      )..add(
          AddRegion(region: widget.region),
        ),
      child: GeoformView<T, U>(
        formBuilder: widget.formBuilder,
        title: widget.title,
        markerBuilder: widget.markerBuilder,
        records: widget.records,
        markers: widget.markers,
        initialPosition: widget.initialPosition,
        initialZoom: widget.initialZoom,
        markerDrawer: widget.markerDrawerBuilder,
        onRecordSelected: widget.onRecordSelected,
        onMarkerSelected: widget.onMarkerSelected,
        registerOnlyWithMarker: widget.registerOnlyWithMarker,
        registerWithManualSelection: widget.registerWithManualSelection,
        followUserPositionAtStart: widget.followUserPositionAtStart,
        bottomInformationBuilder: widget.bottomInformationBuilder,
        bottomActionsBuilder: widget.bottomActionsBuilder,
        bottomInterface: widget.bottomInterface,
        onRegisterPressed: widget.onRegisterPressed,
        updatePosition: widget.updatePosition,
        updateZoom: widget.updateZoom,
        widgetsOnSelectedMarker: widget.widgetsOnSelectedMarker,
        additionalActionWidgets: widget.additionalActionWidgets,
        updateThenForm: widget.updateThenForm,
        polygonsToDraw: widget.polygonsToDraw,
        circlesToDraw: widget.circlesToDraw,
        customTileProvider: widget.customTileProvider,
        urlTemplate: widget.urlTemplate ??
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        setManualModeOnAction: widget.setManualModeOnAction,
      ),
    );
  }
}
