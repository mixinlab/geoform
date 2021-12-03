import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/map.dart';
import 'package:geoformflutter/geoform/user.dart';

class GeoFormWidget extends HookWidget {
  final String name;
  final Widget form;
  final UserInformation userInformation;

  List<GeoFormFixedPoint>? fixedPoints;

  GeoFormWidget({
    Key? key,
    List<GeoFormFixedPoint>? fixedPoints,
    required this.name,
    required this.userInformation,
    required this.form,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeoFormMapWidget(
        name: name,
        form: form,
        // fixedPoints: fixedPoints,
        user: userInformation,
      ),
    );
  }
}
