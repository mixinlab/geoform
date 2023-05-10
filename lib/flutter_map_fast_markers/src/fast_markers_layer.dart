import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/bloc/geoform_bloc.dart';

extension on CustomPoint {
  Offset toOffset() => Offset(x as double, y as double);
}

typedef FastMakerDrawer = void Function(
  Canvas canvas,
  Offset offset,
  FlutterMapState map,
);

class FastMarker {
  FastMarker({
    required this.point,
    this.width = 30.0,
    this.height = 30.0,
    required this.onDraw,
    this.onTap,
    this.show = true,
    AnchorPos? anchorPos,
  }) : anchor = Anchor.forPos(anchorPos, width, height);

  final LatLng point;
  final double width;
  final double height;
  final Anchor anchor;
  final FastMakerDrawer onDraw;
  final Function()? onTap;
  bool? show;
}

class FastMarkersLayer extends StatelessWidget {
  const FastMarkersLayer(this.markers, {super.key});

  final List<FastMarker> markers;
  @override
  Widget build(BuildContext context) {
    final mapState = FlutterMapState.maybeOf(context)!;
    final painter = _FastMarkersPainter(
      mapState,
      markers,
    );
    return BlocListener<GeoformBloc, GeoformState>(
      listenWhen: (previous, current) =>
          previous.tapPosition != current.tapPosition,
      listener: (context, state) {
        painter.onTap(state.tapPosition!.relative);
      },
      child: SizedBox.expand(
        child: CustomPaint(
          painter: painter,
          willChange: true,
        ),
      ),
    );
  }
}

class _FastMarkersPainter extends CustomPainter {
  _FastMarkersPainter(this.map, this.markers) {
    _pxCache = generatePxCache();
  }

  final FlutterMapState map;
  final List<FastMarker> markers;
  final List<MapEntry<Bounds, FastMarker>> markersBoundsCache = [];
  var _lastZoom = -1.0;

  /// List containing cached pixel positions of markers
  /// Should be discarded when zoom changes
  // Has a fixed length of markerOpts.markers.length - better performance:
  // https://stackoverflow.com/questions/15943890/is-there-a-performance-benefit-in-using-fixed-length-lists-in-dart
  var _pxCache = <CustomPoint>[];

  // Calling this every time markerOpts change should guarantee proper length
  List<CustomPoint> generatePxCache() => List.generate(
        markers.length,
        (i) => map.project(markers[i].point),
      );

  //late final markerignoreList=List<bool>.generate(this.options.markers.length,
  //       (int index) => true, growable: true);

  @override
  void paint(Canvas canvas, Size size) {
    final sameZoom = map.zoom == _lastZoom;

    const minimumZoom = 12.9;
    const maximumZoom = 16;
    const minZoomMarkerPercentage = 0.5;
    const slopeShowMarkers =
        (1 - (minZoomMarkerPercentage / 100)) / (maximumZoom - minimumZoom);
    const biasShowMarkers = 1 - (maximumZoom * slopeShowMarkers);

    var markerShowRate = slopeShowMarkers * map.zoom + biasShowMarkers;

    if (map.zoom < minimumZoom) {
      markerShowRate = minZoomMarkerPercentage / 100;
    }
    if (map.zoom >= 16) {
      markerShowRate = 1;
    }

    final showMarkersList = <int>[];
    final hideMarkersList = <int>[];
    var markerNumber = 0;

    for (var i = 0; i < markers.length; i++) {
      (markers[i].show ?? true)
          ? showMarkersList.add(i)
          : hideMarkersList.add(i);
    }

    //this if only works if:
    //1. there is a zoom change && zoom is high enough for showRate to change
    //2. there is a need to turn off markers (to avoid markers going crazy
    // mode on minimumZoomPercentage).
    if ((!sameZoom && map.zoom >= minimumZoom) ||
        markerShowRate < (showMarkersList.length / markers.length)) {
      while (markerShowRate > (showMarkersList.length / markers.length) &&
          (hideMarkersList.isNotEmpty)) {
        //this loop turns on markers
        markerNumber = Random().nextInt(hideMarkersList.length);
        markers[hideMarkersList[markerNumber]].show = true;
        showMarkersList.add(hideMarkersList[markerNumber]);
        hideMarkersList.removeAt(markerNumber);
      }

      while (markerShowRate < (showMarkersList.length / markers.length) &&
          (showMarkersList.isNotEmpty)) {
        //this loop turns off markers
        markerNumber = Random().nextInt(showMarkersList.length);
        markers[showMarkersList[markerNumber]].show = false;
        hideMarkersList.add(showMarkersList[markerNumber]);
        showMarkersList.removeAt(markerNumber);
      }
    }

    markersBoundsCache.clear();
    for (var i = 0; i < markers.length; i++) {
      if ((markers[i].show) ?? true) {
      } else {
        continue;
      } //skips the [i] marker

      final marker = markers[i];

      // Decide whether to use cached point or calculate it
      final pxPoint = sameZoom ? _pxCache[i] : map.project(marker.point);
      if (!sameZoom) {
        _pxCache[i] = pxPoint;
      }

      final topLeft = CustomPoint(
        pxPoint.x - marker.anchor.left,
        pxPoint.y - marker.anchor.top,
      );

      final bottomRight =
          CustomPoint(topLeft.x + marker.width, topLeft.y + marker.height);

      if (!map.pixelBounds
          .containsPartialBounds(Bounds(topLeft, bottomRight))) {
        continue;
      }

      final pos = topLeft - map.pixelOrigin;

      // canvas.scale(18.2 / map.zoom, 18.2 / map.zoom);
      // canvas.scale(2.0);
      // canvas.scale(0.98);

      ///
      ///
      ///
      ///

      marker.onDraw(canvas, pos.toOffset(), map);

      markersBoundsCache.add(
        MapEntry(
          Bounds(pos, pos + CustomPoint(marker.width, marker.height)),
          marker,
        ),
      );
    }
    _lastZoom = map.zoom;
  }

  bool onTap(Offset? pos) {
    final marker = markersBoundsCache.reversed.firstWhereOrNull(
      (e) => e.key.contains(CustomPoint(pos!.dx, pos.dy)),
    );
    if (marker != null) {
      marker.value.onTap?.call();
      return false;
    } else {
      return true;
    }
  }

  @override
  bool shouldRepaint(covariant _FastMarkersPainter oldDelegate) {
    return true;
  }
}
