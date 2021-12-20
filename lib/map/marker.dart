import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DefaultMarker extends HookWidget {
  const DefaultMarker({
    Key? key,
    this.isSelected = false,
  }) : super(key: key);

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle_rounded,
      color: isSelected ? Colors.indigo : Colors.amber,
      size: isSelected ? 20.0 : 16.0,
    );
  }
}
