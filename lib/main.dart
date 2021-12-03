import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geoformflutter/geocore.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geoformflutter/geoform/logger.dart';
import 'package:geoformflutter/geoform/user.dart';
import 'package:geoformflutter/geoform_widget/geoform_widget.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const AppImplementation());
}

// String geoPoints({
//   int? limit = 10,
//   String? baseURL = "https://geocore.innovalab.minsky.cc/api/v1",
//   String? group = "ee73a646-0066-4f4a-8ee9-358e77ebba7f",
// }) =>
//     '$baseURL/group/$group?limit=$limit';

class AppImplementation extends HookWidget {
  const AppImplementation({
    Key? key,
  }) : super(key: key);

  // {
  //   // super(key: key);
  // }

  @override
  Widget build(BuildContext context) {
    // final points = useState<List<GeoFormFixedPoint>?>([]);

    // useEffect(() {
    //   Dio().get<List<dynamic>>(geoPoints(limit: 10)).then((result) {
    //     points.value = result.data
    //         ?.map((e) => GeoPoint.fromJson(e))
    //         .map(
    //           (e) => GeoFormFixedPoint(
    //             latLng: LatLng(
    //               e.lat ?? 0.0,
    //               e.lng ?? 0.0,
    //             ),
    //             metadata: {
    //               "id": e.id,
    //               "unicode": e.unicode,
    //             },
    //           ),
    //         )
    //         .toList();
    //   });
    // }, []);

    // logger.d(points.value);

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
      home: GeoFormWidget(
        name: "Rociados Pendientes",
        form: const Text("form"),
        // fixedPoints: points.value,
        userInformation: UserInformation(
          id: "1",
          name: "Bregy Malpartida",
        ),
      ),
    );
  }
}
