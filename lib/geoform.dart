import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geoform/view/view.dart';

class GeoformContext {
  GeoformContext({
    required this.currentPosition,
    this.selectedMarker,
    this.extra,
  });

  final LatLng currentPosition;
  final GeoformMarkerDatum? selectedMarker;
  final Map<String, dynamic>? extra;
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
    this.records, // Future<List<T>>.value([]),
    this.markers,
    this.markerBuilder, // defaultMarkerBuilder<U>(),
    this.initialPosition,
    this.initialZoom,
    this.markerDrawerBuilder,
    this.onRecordSelected,
    this.onMarkerSelected,
    this.registerOnlyWithMarker = false,
    this.followUserPositionAtStart = true,
  }) : super(key: key);

  final String title;
  final GeoformFormBuilder<U> formBuilder;
  final bool registerOnlyWithMarker;
  final bool followUserPositionAtStart;

  final GeoformMarkerBuilder<U>? markerBuilder;
  final GeoformMarkerDrawerBuilder<U>? markerDrawerBuilder;
  final void Function(U marker)? onMarkerSelected;

  final Future<List<T>>? records;
  final List<U>? markers;
  final void Function(T record)? onRecordSelected;

  final LatLng? initialPosition;
  final double? initialZoom;

  @override
  Widget build(BuildContext context) {
    return GeoformView<T, U>(
      formBuilder: formBuilder,
      title: title,
      markerBuilder: markerBuilder,
      records: records,
      markers: markers,
      initialPosition: initialPosition,
      initialZoom: initialZoom,
      markerDrawerBuilder: markerDrawerBuilder,
      onRecordSelected: onRecordSelected,
      onMarkerSelected: onMarkerSelected,
      registerOnlyWithMarker: registerOnlyWithMarker,
      followUserPositionAtStart: followUserPositionAtStart,
    );
  }
}
