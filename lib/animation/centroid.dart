import 'package:latlong2/latlong.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_markers_layer.dart';

LatLng getCentroid({required List<FastMarker> markers, LatLng? defaultCenter}) {
  if (markers.isEmpty) {
    return defaultCenter ?? LatLng(0, 0);
  }

  var latitude = 0.0;
  var longitude = 0.0;

  for (final element in markers) {
    latitude += element.point.latitude;
    longitude += element.point.longitude;
  }

  final total = markers.length;

  latitude /= total;
  longitude /= total;

  return LatLng(latitude, longitude);
}
