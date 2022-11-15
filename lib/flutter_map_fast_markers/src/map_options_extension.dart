import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

extension MapOptionsCopyWith on MapOptions {
  MapOptions copyWith({
    Crs? crs,
    double? zoom,
    double? rotation,
    bool? debugMultiFingerGestureWinner,
    bool? enableMultiFingerGestureRace,
    double? rotationThreshold,
    int? rotationWinGestures,
    double? pinchZoomThreshold,
    int? pinchZoomWinGestures,
    double? pinchMoveThreshold,
    int? pinchMoveWinGestures,
    bool? enableScrollWheel,
    double? minZoom,
    double? maxZoom,
    int? interactiveFlags,
    TapCallback? onTap,
    LongPressCallback? onLongPress,
    PositionCallback? onPositionChanged,
    Function()? onMapReady,
    bool? slideOnBoundaries,
    Size? screenSize,
    bool? adaptiveBoundaries,
    LatLng? center,
    LatLngBounds? bounds,
    FitBoundsOptions? boundsOptions,
    LatLng? swPanBoundary,
    LatLng? nePanBoundary,
  }) {
    return MapOptions(
      crs: crs ?? this.crs,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      debugMultiFingerGestureWinner:
          debugMultiFingerGestureWinner ?? this.debugMultiFingerGestureWinner,
      enableMultiFingerGestureRace:
          enableMultiFingerGestureRace ?? this.enableMultiFingerGestureRace,
      rotationThreshold: rotationThreshold ?? this.rotationThreshold,
      rotationWinGestures: rotationWinGestures ?? this.rotationWinGestures,
      pinchZoomThreshold: pinchZoomThreshold ?? this.pinchZoomThreshold,
      pinchZoomWinGestures: pinchZoomWinGestures ?? this.pinchZoomWinGestures,
      pinchMoveThreshold: pinchMoveThreshold ?? this.pinchMoveThreshold,
      pinchMoveWinGestures: pinchMoveWinGestures ?? this.pinchMoveWinGestures,
      enableScrollWheel: enableScrollWheel ?? this.enableScrollWheel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      interactiveFlags: interactiveFlags ?? this.interactiveFlags,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onPositionChanged: onPositionChanged ?? this.onPositionChanged,
      onMapReady: onMapReady ?? this.onMapReady,
      slideOnBoundaries: slideOnBoundaries ?? this.slideOnBoundaries,
      screenSize: screenSize ?? this.screenSize,
      adaptiveBoundaries: adaptiveBoundaries ?? this.adaptiveBoundaries,
      center: center ?? this.center,
      bounds: bounds ?? this.bounds,
      boundsOptions: boundsOptions ?? this.boundsOptions,
    );
  }
}

// extension RawTap on MapGesture {

// }
