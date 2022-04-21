import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform_markers.dart';

typedef GeoformBottomDisplayBuilder<U extends GeoformMarkerDatum> = Widget
    Function(
  BuildContext context,
  LatLng? currentPosition,
  U? selectedMarker,
);

class GeoformBottomInterface<U extends GeoformMarkerDatum>
    extends StatelessWidget {
  const GeoformBottomInterface({
    required this.title,
    required this.registerOnlyWithMarker,
    required this.selectedMarker,
    this.currentPosition,
    this.informationBuilder,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  final String title;
  final U? selectedMarker;
  final LatLng? currentPosition;

  final bool registerOnlyWithMarker;

  final GeoformBottomDisplayBuilder<U>? informationBuilder;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: (informationBuilder != null)
          ? informationBuilder!(context, currentPosition, selectedMarker)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: const TextStyle(fontSize: 20)),
                _LatLongInfo(currentPosition: currentPosition),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    animationDuration: const Duration(milliseconds: 300),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.rubik(fontSize: 18),
                  ),
                  child: Text("l10n.registerText"),
                )
              ],
            ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({Key? key, required this.title, required this.value})
      : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title: $value',
      style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
    );
  }
}

class _LatLongInfo extends StatelessWidget {
  const _LatLongInfo({Key? key, this.currentPosition}) : super(key: key);

  final LatLng? currentPosition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: currentPosition == null
          ? const Center(child: CupertinoActivityIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Info(
                  title: "l10n.geoformLatitudeText",
                  value: currentPosition!.latitude.toString(),
                ),
                const SizedBox(height: 8),
                Info(
                  title: "l10n.geoformLongitudeText",
                  value: currentPosition!.longitude.toString(),
                ),
              ],
            ),
    );
  }
}
