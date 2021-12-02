import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/map.dart';

class GeoFormWidget extends HookWidget {
  final String name;
  final Widget form;

  List<GeoFormFixedPoint>? fixedPoints;

  GeoFormWidget({
    Key? key,
    required this.name,
    required this.form,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeoFormMapWidget(),
    );
  }
}
