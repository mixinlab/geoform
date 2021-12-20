import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicTextualInformation extends HookWidget {
  BasicTextualInformation({
    Key? key,
    required this.selectedPosition,
    this.metadata,
  }) : super(key: key);

  Position selectedPosition;
  Map? metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Latitude: ${selectedPosition.latitude}",
          style: GoogleFonts.openSans(
            fontSize: 14.0,
            color: Colors.grey,
            // fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Longitude: ${selectedPosition.longitude}",
          style: GoogleFonts.openSans(
            fontSize: 14.0,
            color: Colors.grey,
            // fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Accuracy: ${selectedPosition.accuracy.toStringAsFixed(2)}",
          style: GoogleFonts.openSans(
            fontSize: 14.0,
            color: Colors.grey,
            // fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Unicode: ${metadata?["unicode"]}',
          style: GoogleFonts.openSans(
            fontSize: 14.0,
            color: Colors.grey,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
