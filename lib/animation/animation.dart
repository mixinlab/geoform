import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Animates the map movement to a new location with a zoom effect.
///
/// [mapController] - Controller for the map, used to update location and zoom.
/// [animationController] - Controller for the animation, manages the transition.
/// [destLocation] - The destination `LatLng` where the map will move to.
/// [destZoom] - The zoom level at the destination.
void animatedMapMove(
  MapController? mapController,
  AnimationController animationController,
  LatLng destLocation,
  double destZoom,
) {
  final latTween = Tween<double>(
    begin: mapController!.center.latitude,
    end: destLocation.latitude,
  );

  final lngTween = Tween<double>(
    begin: mapController.center.longitude,
    end: destLocation.longitude,
  );

  final zoomTween = Tween<double>(
    begin: mapController.zoom,
    end: destZoom,
  );

  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.fastOutSlowIn,
  );

  animationController
    ..reset()
    ..addListener(() {
      mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    })
    ..forward();
}
