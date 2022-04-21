import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geoform/flutter_map_fast_markers/flutter_map_fast_markers.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class FastMarkersLayerOptions extends LayerOptions {
  FastMarkersLayerOptions({
    Key? key,
    this.markers = const [],
    this.tapStream,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);

  final List<FastMarker> markers;
  final StreamController<TapPosition>? tapStream;
}
