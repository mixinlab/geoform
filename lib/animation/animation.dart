import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  // TODO(amaru): We need to deactivate any action button when we are animating the map.
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

  //animationController.addStatusListener((status) {
  //  if (status == AnimationStatus.completed) {
  //    // animationController.removeListener(() {});
  //    // animationController.dispose();
  //    // animationController.reset();
  //  } else if (status == AnimationStatus.dismissed) {
  //    // animationController.removeListener(mapMove);
  //    // animationController.reset();
  //  }
  //});

  //animationController.forward();
}
