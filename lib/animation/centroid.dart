import 'package:latlong2/latlong.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_markers_layer.dart';

LatLng getCentroid({required List<FastMarker> markers, LatLng? defaultCenter}) {
  if (markers.isEmpty) {
    return defaultCenter ?? LatLng(0, 0);
  }

  var _latitude = 0.0;
  var _longitude = 0.0;

  for (final element in markers) {
    _latitude += element.point.latitude;
    _longitude += element.point.longitude;
  }

  final _total = markers.length;

  _latitude /= _total;
  _longitude /= _total;

  return LatLng(_latitude, _longitude);
}
