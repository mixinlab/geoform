import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/map.dart';
import 'package:geoformflutter/geoform/user.dart';

class GeoFormWidget extends HookWidget {
  final String name;
  final Widget form;
  final UserInformation userInformation;

  final List<GeoFormFixedPoint>? points;

  String? registerVerb;

  GeoFormWidget({
    Key? key,
    this.points,
    required this.name,
    required this.userInformation,
    required this.form,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("widget build: ${points?.length}");

    return Scaffold(
      body: GeoFormMapWidget(
        name: name,
        form: form,
        points: points,
        user: userInformation,
      ),
    );
  }
}
