import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_markers_layer.dart';
import 'package:geoform/geoform.dart';
import 'package:geoform/bloc/geoform_bloc.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:latlong2/latlong.dart';

// Definición de MyRecordType
class MyRecordType {
  final String id;
  final String name;
  final String description;

  MyRecordType(
      {required this.id, required this.name, required this.description});
}

// Definición de MyMarkerType
class MyMarkerType extends GeoformMarkerDatum {
  final String title;
  final String description;

  MyMarkerType({
    required LatLng position,
    this.title = "",
    this.description = "",
  }) : super(position: position);
}

void main() {
  group('Geoform Tests', () {
    testWidgets('Geoform creates a Map', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Geoform<MyRecordType, MyMarkerType>(
          formBuilder: (_, __) => Container(),
          title: 'Test Map',
        ),
      ));

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('Geoform displays title in BottomInterface',
        (WidgetTester tester) async {
      const testTitle = 'Test Map';
      await tester.pumpWidget(MaterialApp(
        home: Geoform<MyRecordType, MyMarkerType>(
          formBuilder: (_, __) => Container(),
          title: testTitle,
        ),
      ));

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('GeoformBloc emits correct state on marker selection',
        (WidgetTester tester) async {
      final testMarkerData = MyMarkerType(
          position: LatLng(0, 0), title: "Test", description: "Test Marker");

      FastMarker buildTestMarker(MyMarkerType markerData) {
        return FastMarker(
          point: markerData.position,
          onDraw: (Canvas canvas, Offset offset, FlutterMapState map) {},
        );
      }

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider(
          create: (_) => GeoformBloc<MyMarkerType>(),
          child: Geoform<MyRecordType, MyMarkerType>(
            formBuilder: (_, __) => Container(),
            title: 'Test Map',
            markerBuilder: (markerData) => buildTestMarker(markerData),
          ),
        ),
      ));

      BlocProvider.of<GeoformBloc<MyMarkerType>>(
              tester.element(find.byType(Geoform<MyRecordType, MyMarkerType>)))
          .add(SelectMarker(marker: testMarkerData));

      await tester.pumpAndSettle();

      final GeoformBloc<MyMarkerType> bloc = tester
          .element(find.byType(Geoform<MyRecordType, MyMarkerType>))
          .read<GeoformBloc<MyMarkerType>>();
      expect(bloc.state.selectedMarker, equals(testMarkerData));
    });
  });
}
