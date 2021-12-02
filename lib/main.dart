import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geoformflutter/geoform/geolocation.dart';
import 'package:geoformflutter/geoform/logger.dart';
import 'package:geoformflutter/geoform_widget/geoform_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

// class GeoFormStaticLayer extends StatefulWidget {
//   final GeoFormFixedPoint fixedPoint;

//   const GeoFormStaticLayer({Key? key, required this.fixedPoint}) : super(key: key);

//   @override
//   _GeoFormStaticLayerState createState() => _GeoFormStaticLayerState();
// }

// class _GeoFormStaticLayerState extends State<GeoFormStaticLayer> {
//   bool _selected = false;
//   final GeoFormFixedPoint fixedPoint;

//  const _GeoFormStaticLayerState({
//     Key? key,
//     required this.fixedPoint,
//   }) : super(key: key, fixedPoint: this.fixedPoint);

//   final LatLng fixedPoint;

//   @override
//   Widget build(BuildContext context) {
//     return MarkerLayerWidget(
//       options: MarkerLayerOptions(
//         markers: [
//           Marker(
//             width: 32.0,
//             height: 32.0,
//             point: fixedPoint,
//             builder: (context) {
//               return GestureDetector(
//                 onTap: () {
//                   print("Tapped on marker");
//                   const snackBar = SnackBar(content: Text('Tap'));
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 },
//                 child: const PrefixedPointWidget(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class GeoFormStaticLayer extends StatelessWidget {

// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}

// class MapPage extends StatefulWidget {
//   const MapPage({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
//   final MapController mapController = MapController();
//   var userPosition = LatLng(-12.04589, -77.019346);
//   var fixedPoint = LatLng(-12.136877, -77.020336);
//   var accuracy = 0.0;
//   GeoFormMode currentMode = GeoFormMode.auto;

//   @override
//   void initState() {
//     super.initState();
//     //  mapController
//     //  WidgetsBinding.instance?.addPostFrameCallback((_) => ready(context));
//     _ready(context);
//   }

//   _updateCurrentPosition(Position value, {bool follow = false}) {
//     setState(
//       () {
//         userPosition = LatLng(value.latitude, value.longitude);
//         accuracy = value.accuracy;
//         logger.d(userPosition);
//         if (follow) {
//           _animatedMapMove(userPosition, 16);
//         }
//       },
//     );
//   }

//   Future<void> _showMyDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('AlertDialog Title'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: const <Widget>[
//                 Text('This is a demo alert dialog.'),
//                 Text('Would you like to approve of this message?'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Approve'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // @override
//   void _ready(BuildContext context) {
//     determinePosition()
//         .then((value) => _updateCurrentPosition(value, follow: true))
//         .catchError((error) => logger.e(error))
//         .whenComplete(() {
//       watchUserPosition()
//           .then(
//             (stream) => stream.listen(
//               _updateCurrentPosition,
//               onError: (error) => logger.e(error),
//             ),
//           )
//           .catchError((error) => logger.e(error));
//     });
//   }

 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // bottomSheet: Container(
//       //   child: Text('Hello World'),
//       // ),
//       body: 
//     );
//   }
// }
