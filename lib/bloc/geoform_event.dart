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

class GeoformContextUpdated extends GeoformEvent {
  const GeoformContextUpdated({required this.context});

  final GeoformContext context;

  @override
  List<Object?> get props => [context];
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

class ChangeMapPosition extends GeoformEvent {
  const ChangeMapPosition({
    this.position,
  });
  final LatLng? position;

  @override
  List<Object?> get props => [position];
}

class ChangeMarkers extends GeoformEvent {
  const ChangeMarkers({
    required this.markers,
  });
  final List<FastMarker> markers;

  @override
  List<Object?> get props => [markers];
}

class AddAnimation extends GeoformEvent {
  const AddAnimation({
    required this.controller,
  });
  final AnimationController controller;

  @override
  List<Object?> get props => [controller];
}

class ChangeActivateAction extends GeoformEvent {
  const ChangeActivateAction({required this.isActivated});
  final bool isActivated;

  @override
  List<Object?> get props => [isActivated];
}
