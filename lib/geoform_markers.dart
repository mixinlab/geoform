import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/flutter_map_fast_markers/flutter_map_fast_markers.dart';

// @immutable
abstract class GeoformMarkerDatum {
  const GeoformMarkerDatum({
    required this.position,
    // this.sizeMeters,
  });

  final LatLng position;
  // final double? sizeMeters;
}

typedef GeoformMarkerBuilder<U extends GeoformMarkerDatum> = FastMarker
    Function(U datum);

typedef GeoformMarkerDrawerBuilder<U extends GeoformMarkerDatum>
    = FastMakerDrawer Function(U datum);

typedef GeoformMarkerTapCallback<U extends GeoformMarkerDatum> = void Function(
  U datum,
);

final redPaint = Paint()
  ..color = Colors.orange
  ..style = PaintingStyle.fill;

GeoformMarkerBuilder<U> defaultMarkerBuilder<U extends GeoformMarkerDatum>({
  Size size = const Size(18, 18),
  GeoformMarkerDrawerBuilder<U>? customDraw,
  GeoformMarkerTapCallback<U>? onTap,
}) {
  const alphaSmall = -2.09;
  const zoomMaxFactorSmall = 34;
  const smallPointSize = 3.8;
  return <T>(T datum) {
    final v = datum as GeoformMarkerDatum;
    final width = size.width;
    final height = size.height;

    return FastMarker(
      point: v.position,
      width: width,
      height: height,
      anchorPos: AnchorPos.align(AnchorAlign.center),
      onDraw: customDraw == null
          ? (canvas, offset, map) {
              final calculatedSmallPoint = alphaSmall +
                  (pow(map.zoom, 1.5) / zoomMaxFactorSmall * smallPointSize);
              canvas.drawCircle(
                offset + Offset(calculatedSmallPoint*2, calculatedSmallPoint*2),
                calculatedSmallPoint,
                redPaint,
              );
            }
          : customDraw(v as U),
      onTap: () => onTap == null ? null : onTap(v as U),
    );
  };
}

// <T extends GeoformMarkerDatum>
