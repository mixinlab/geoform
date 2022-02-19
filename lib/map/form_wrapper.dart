import 'package:flutter/material.dart';
import 'package:geoform/entities.dart';
import 'package:geoform/map/basic_information.dart';
import 'package:geolocator/geolocator.dart';

class FormWrapperOptions {
  final Key? key;
  final String title;
  final bool withFloatingButton;
  final String floatingButtonLabel;
  final void Function()? onFloatingButtonPressed;
  final IconData icon;

  FormWrapperOptions({
    this.key,
    required this.title,
    this.withFloatingButton = true,
    this.floatingButtonLabel = "Registrar",
    this.icon = Icons.save,
    this.onFloatingButtonPressed,
  });
}

class GeoFormFormWrapperWidget extends StatelessWidget {
  final Widget form;
  final FormWrapperOptions formWrapperOptions;

  final ValueNotifier<Position> selectedPosition;
  final ValueNotifier<GeoFormFixedPoint?> selectedFixedPoint;

  const GeoFormFormWrapperWidget({
    Key? key,
    required this.form,
    required this.formWrapperOptions,
    required this.selectedPosition,
    required this.selectedFixedPoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formWrapperOptions.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          formWrapperOptions.onFloatingButtonPressed?.call();
          Navigator.of(context).pop();
        },
        label: Text(formWrapperOptions.floatingButtonLabel),
        icon: Icon(formWrapperOptions.icon),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                BasicTextualInformation(
                  selectedPosition: selectedPosition.value,
                  metadata: selectedFixedPoint.value?.metadata,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: form,
            ),
          ],
        ),
      ),
    );
  }
}
