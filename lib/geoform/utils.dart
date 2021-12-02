import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

LatLng latLngFromPosition(Position position) {
  return LatLng(position.latitude, position.longitude);
}
