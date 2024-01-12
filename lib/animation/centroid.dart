import 'package:geoform/geoform_markers.dart';
import 'package:latlong2/latlong.dart';

/// Calculates the centroid (geographical center) of a set of markers.
///
/// [markers] - A list of `GeoformMarkerDatum` representing the markers on the map.
/// [defaultCenter] - An optional default `LatLng` returned if the markers list is empty.
/// ///
/// Returns the centroid of the markers by averaging their latitude and longitude.
/// If the marker list is empty, returns [defaultCenter] or a default `LatLng(0, 0)`
/// if no [defaultCenter] is provided.
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
