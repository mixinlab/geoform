import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform_markers.dart';

class Info extends StatelessWidget {
  const Info({Key? key, required this.title, required this.value})
      : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        '$title: $value',
        style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}

class BottomInformation<U extends GeoformMarkerDatum> extends StatefulWidget {
  const BottomInformation({
    this.selectedMarker,
    this.currentPosition,
    Key? key,
  }) : super(key: key);

  final U? selectedMarker;
  final LatLng? currentPosition;

  @override
  State<BottomInformation<U>> createState() => _BottomInformationState<U>();
}

class _BottomInformationState<U extends GeoformMarkerDatum>
    extends State<BottomInformation<U>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Info(
              title: "Position",
              value: (widget.selectedMarker == null)
                  ? '-'
                  : "${widget.selectedMarker?.position.latitude.toStringAsFixed(5)}, ${widget.selectedMarker?.position.longitude.toStringAsFixed(5)}",
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
