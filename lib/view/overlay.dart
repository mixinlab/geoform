import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform_markers.dart';

class GeoformMarkerOverlay extends StatelessWidget {
  const GeoformMarkerOverlay({
    this.selectedMarker,
    this.mapController,
    this.onTapOutside,
    Key? key,
  }) : super(key: key);

  final GeoformMarkerDatum? selectedMarker;
  final MapController? mapController;
  final void Function()? onTapOutside;

  Size _getPixelPositionFromLatLngAndBounds(
    BoxConstraints constraints, {
    LatLng? point,
    LatLngBounds? bounds,
    Offset? offset,
  }) {
    if (point == null || bounds == null) {
      return Size.zero;
    }

    final distLat = bounds.southEast.latitude - bounds.northWest.latitude;
    final distLng = bounds.southEast.longitude - bounds.northWest.longitude;

    final diffLat = point.latitude - bounds.northWest.latitude;
    final diffLng = point.longitude - bounds.northWest.longitude;

    final pixelX = diffLat / distLat * constraints.maxHeight;
    final pixelY = diffLng / distLng * constraints.maxWidth;

    return Size(pixelY, pixelX) + (offset ?? Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _highlightPosition = _getPixelPositionFromLatLngAndBounds(
          constraints,
          point: selectedMarker?.position,
          bounds: mapController?.bounds,
          offset: const Offset(-11.5, -12),
        );

        return GestureDetector(
          onTap: onTapOutside,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                // width: 120,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.srcOut,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),
                      Positioned(
                        top: _highlightPosition.height,
                        left: _highlightPosition.width,
                        // alignment: Alignment.topCenter,
                        child: AnimatedContainer(
                          duration: const Duration(
                            seconds: 1,
                          ),
                          // margin: const EdgeInsets.only(top: 60),
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
