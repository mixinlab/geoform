import 'package:flutter/material.dart';
import 'package:geoformflutter/geoform/entities.dart';

class GeoFormOptions {
  final String name;
  final Widget form;

  List<GeoFormFixedPoint>? fixedPoints;

  GeoFormOptions({
    required this.name,
    required this.form,
    this.fixedPoints,
  });
}
