import 'package:flutter/material.dart';

class GeoformActionButton extends StatelessWidget {
  const GeoformActionButton({
    required this.icon,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  final Icon icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      // color: Colors.transparent,
      elevation: 4,
      child: Ink(
        decoration: const ShapeDecoration(
          // color: Colors.black,
          // color: ,
          shape: CircleBorder(),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}
