import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class Geoform<T, U extends GeoformMarkerDatum> extends StatelessWidget {
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
    this.bottomInterface,
    this.updatePosition,
    this.updateZoom,
    this.updateThenForm,
    this.polygonsToDraw = const [],
    this.region,
    this.regionName,
    this.customTileProvider,
    this.mapProvider = MapProvider.openStreetMap,
    this.urlTemplate,
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
  final GeoformBottomInterface? bottomInterface;

  // Functions to update pos and zoom
  final void Function(LatLng?)? updatePosition;
  final void Function(double?)? updateZoom;

  final void Function()? updateThenForm;

  final List<FastPolygon> polygonsToDraw;

  final DownloadableRegion? region;
  final String? regionName;

  final Widget? customTileProvider;
  final MapProvider mapProvider;
  final String? urlTemplate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeoformBloc(
        regionName: regionName,
        mapProvider: mapProvider,
      )..add(
          AddRegion(region: region),
        ),
      child: GeoformView<T, U>(
        formBuilder: formBuilder,
        title: title,
        markerBuilder: markerBuilder,
        records: records,
        markers: markers,
        initialPosition: initialPosition,
        initialZoom: initialZoom,
        markerDrawer: markerDrawerBuilder,
        onRecordSelected: onRecordSelected,
        onMarkerSelected: onMarkerSelected,
        registerOnlyWithMarker: registerOnlyWithMarker,
        registerWithManualSelection: registerWithManualSelection,
        followUserPositionAtStart: followUserPositionAtStart,
        bottomInformationBuilder: bottomInformationBuilder,
        bottomInterface: bottomInterface,
        updatePosition: updatePosition,
        updateZoom: updateZoom,
        updateThenForm: updateThenForm,
        polygonsToDraw: polygonsToDraw,
        customTileProvider: customTileProvider,
        urlTemplate:
            urlTemplate ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      ),
    );
  }
}
