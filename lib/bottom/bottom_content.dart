import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/bottom/bottom_widgets.dart';
import 'package:geoform/geoform_markers.dart';

typedef GeoformBottomDisplayBuilder<U extends GeoformMarkerDatum> = Widget
    Function(BuildContext, LatLng?, U?);

typedef GeoformBottomActionsBuilder<U extends GeoformMarkerDatum> = Widget
    Function(
  BuildContext,
  bool,
  TextEditingController?,
  U?,
  void Function()?,
  void Function()?,
);

class GeoformBottomInterface<U extends GeoformMarkerDatum>
    extends StatelessWidget {
  const GeoformBottomInterface({
    required this.title,
    required this.registerOnlyWithMarker,
    required this.selectedMarker,
    this.currentPosition,
    this.informationBuilder,
    this.actionsBuilder,
    this.onRegisterPressed,
    this.onActionPressed,
    this.actionTextController,
    this.actionActivated = false,
    Key? key,
  }) : super(key: key);

  final String title;
  final U? selectedMarker;
  final LatLng? currentPosition;

  final bool registerOnlyWithMarker;

  final GeoformBottomDisplayBuilder<U>? informationBuilder;
  final GeoformBottomActionsBuilder<U>? actionsBuilder;

  final void Function()? onRegisterPressed;
  final void Function()? onActionPressed;

  final bool actionActivated;

  final TextEditingController? actionTextController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          if (informationBuilder != null)
            informationBuilder!(context, currentPosition, selectedMarker)
          else
            BottomInformation(selectedMarker: selectedMarker),
          if (actionsBuilder != null)
            actionsBuilder!(
              context,
              actionActivated,
              actionTextController,
              selectedMarker,
              onActionPressed,
              onRegisterPressed,
            )
          else
            BottomActions(onRegisterPressed: onRegisterPressed),
        ],
      ),
    );
  }
}
