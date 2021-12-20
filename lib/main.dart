import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geoformflutter/geocore.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/map/map.dart';
import 'package:geoformflutter/geoform/user.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const AppImplementation());
}

String geoPoints({
  int? limit = 10,
  String? baseURL = "https://geocore.innovalab.minsky.cc/api/v1",
  String? group = "ee73a646-0066-4f4a-8ee9-358e77ebba7f",
}) =>
    '$baseURL/group/$group?limit=$limit';

class AppImplementation extends HookWidget {
  const AppImplementation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final points = useState<List<GeoFormFixedPoint>?>([]);

    useEffect(() {
      Dio().get<List<dynamic>>(geoPoints(limit: 100)).then(
        (result) {
          points.value = result.data
              ?.map((e) => GeoPoint.fromJson(e))
              .map(
                (e) => GeoFormFixedPoint(
                  latLng: LatLng(
                    e.lat ?? 0.0,
                    e.lng ?? 0.0,
                  ),
                  metadata: {
                    "id": e.id,
                    "unicode": e.unicode,
                  },
                ),
              )
              .toList(growable: false);
        },
      );
    }, []);

    // logger.d(points.value);
    // print("app build: ${points.value?.length}");

    return MaterialApp(
      title: 'Flutter Map Test',
      // themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        body: GeoFormMapWidget(
          name: "Rociados Pendientes",
          form: const Text("form"),
          points: points.value,
          user: UserInformation(
            id: "1",
            name: "Bregy Malpartida",
          ),
        ),
      ),
    );
  }
}
