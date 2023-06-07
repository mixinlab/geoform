part of 'geoform_bloc.dart';

abstract class GeoformEvent extends Equatable {
  const GeoformEvent();
}

class ManualChanged extends GeoformEvent {
  const ManualChanged({required this.manual});

  final bool manual;

  @override
  List<Object?> get props => [manual];
}

class GeoformOnTap extends GeoformEvent {
  const GeoformOnTap({required this.tapPosition});
  final TapPosition tapPosition;

  @override
  List<Object?> get props => [tapPosition];
}

class AddRegion extends GeoformEvent {
  const AddRegion({
    this.region,
  });
  final DownloadableRegion? region;

  @override
  List<Object?> get props => [
        region,
      ];
}

class InitLocationService extends GeoformEvent {
  const InitLocationService();

  @override
  List<Object?> get props => [];
}

class UpdateMarkers<U extends GeoformMarkerDatum> extends GeoformEvent {
  const UpdateMarkers({
    required this.markers,
  });
  final List<U> markers;

  @override
  List<Object?> get props => [markers];
}

class UpdatePolygons extends GeoformEvent {
  const UpdatePolygons({
    required this.polygons,
  });
  final List<FastPolygon> polygons;

  @override
  List<Object?> get props => [polygons];
}

class UpdateCircles extends GeoformEvent {
  const UpdateCircles({
    required this.circles,
  });
  final List<CircleMarker> circles;

  @override
  List<Object?> get props => [circles];
}

class ChangeActivateAction extends GeoformEvent {
  const ChangeActivateAction({required this.isActivated});
  final bool isActivated;

  @override
  List<Object?> get props => [isActivated];
}

class SelectMarker<U extends GeoformMarkerDatum> extends GeoformEvent {
  const SelectMarker({required this.marker});
  final U? marker;

  @override
  List<Object?> get props => [marker];
}

class UpdateMapPosition extends GeoformEvent {
  const UpdateMapPosition({required this.mapPosition});
  final LatLng? mapPosition;
  @override
  List<Object?> get props => [mapPosition];
}
