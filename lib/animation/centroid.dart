import 'package:geoform/geoform_markers.dart';
import 'package:latlong2/latlong.dart';

LatLng getCentroid(
    {required List<GeoformMarkerDatum> markers, LatLng? defaultCenter}) {
  if (markers.isEmpty) {
    return defaultCenter ?? LatLng(0, 0);
  }

  var latitude = 0.0;
  var longitude = 0.0;

  for (final element in markers) {
    latitude += element.position.latitude;
    longitude += element.position.longitude;
  }

  final total = markers.length;

  latitude /= total;
  longitude /= total;

  return LatLng(latitude, longitude);
}
