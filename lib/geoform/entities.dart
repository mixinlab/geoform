import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geoformflutter/geoform/geolocation.dart';
import 'package:geoformflutter/geoform/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GeoFormFixedPoint {
  LatLng latLng;
  Map<String, dynamic>? metadata;

  GeoFormFixedPoint({required this.latLng, this.metadata});
}
