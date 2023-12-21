import 'package:flutter/material.dart';
import 'package:geoform/geoform.dart';
import 'package:geoform/bottom/bottom_widgets.dart';
import 'package:geoform/geoform_markers.dart';

typedef GeoformBottomDisplayBuilder<U extends GeoformMarkerDatum> = Widget
    Function(BuildContext, GeoformContext<U>);

typedef GeoformBottomActionsBuilder<U extends GeoformMarkerDatum>
    = Widget Function(BuildContext, bool, TextEditingController?,
        GeoformContext<U>, void Function()?, void Function()?);

class GeoformBottomInterface<U extends GeoformMarkerDatum>
    extends StatelessWidget {
  const GeoformBottomInterface({
    required this.title,
    required this.registerOnlyWithMarker,
    required this.geoformContext,
    this.informationBuilder,
    this.actionsBuilder,
    this.onRegisterPressed,
    this.onActionPressed,
    this.actionTextController,
    this.actionActivated = false,
    Key? key,
  }) : super(key: key);

  final String title;
  final GeoformContext<U> geoformContext;

  final bool registerOnlyWithMarker;

  final GeoformBottomDisplayBuilder<U>? informationBuilder;
  final GeoformBottomActionsBuilder<U>? actionsBuilder;

  final void Function(GeoformContext<U>)? onRegisterPressed;
  final void Function(GeoformContext<U>)? onActionPressed;

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
            informationBuilder!(context, geoformContext)
          else
            BottomInformation<U>(
              selectedMarker: geoformContext.geostate.selectedMarker,
            ),
          if (actionsBuilder != null)
            actionsBuilder!(
              context,
              actionActivated,
              actionTextController,
              geoformContext,
              () => onActionPressed != null
                  ? onActionPressed!(geoformContext)
                  : null,
              () => onRegisterPressed != null
                  ? onRegisterPressed!(geoformContext)
                  : null,
            )
          else
            BottomActions(
              onRegisterPressed: () => onRegisterPressed != null
                  ? onRegisterPressed!(geoformContext)
                  : null,
            ),
        ],
      ),
    );
  }
}
