part of 'geoform_bloc.dart';

enum MapProvider { openStreetMap, customProvider, vectorProvider }

class GeoformState<U extends GeoformMarkerDatum> extends Equatable {
  const GeoformState._({
    this.markers = const [],
    this.polygonsToDraw = const [],
    this.circlesToDraw = const [],
    this.manual = false,
    this.tapPosition,
    this.regionName,
    this.isDownloading = false,
    this.mapProvider = MapProvider.openStreetMap,
    this.isActionActivated = false,
    this.selectedMarker,
    this.userLocation,
  });

  final List<U> markers;
  final List<FastPolygon> polygonsToDraw;
  final List<CircleMarker> circlesToDraw;
  final bool manual;
  final TapPosition? tapPosition;
  final String? regionName;
  final bool isDownloading;
  final MapProvider mapProvider;
  final bool isActionActivated;
  final U? selectedMarker;
  final Position? userLocation;

  GeoformState<U> copyWith({
    List<U>? markers,
    List<FastPolygon>? polygonsToDraw,
    List<CircleMarker>? circlesToDraw,
    AnimationController? animationController,
    bool? manual,
    TapPosition? tapPosition,
    String? regionName,
    bool? isDownloading,
    MapProvider? mapProvider,
    bool? isActionActivated,
    Position? userLocation,
  }) {
    return GeoformState._(
      markers: markers ?? this.markers,
      polygonsToDraw: polygonsToDraw ?? this.polygonsToDraw,
      circlesToDraw: circlesToDraw ?? this.circlesToDraw,
      manual: manual ?? this.manual,
      tapPosition: tapPosition ?? this.tapPosition,
      regionName: regionName ?? this.regionName,
      isDownloading: isDownloading ?? this.isDownloading,
      mapProvider: mapProvider ?? this.mapProvider,
      isActionActivated: isActionActivated ?? this.isActionActivated,
      userLocation: userLocation ?? this.userLocation,
      selectedMarker: selectedMarker,
    );
  }

  GeoformState<U> changeMarker({
    U? selectedMarker,
  }) {
    return GeoformState._(
      markers: markers,
      polygonsToDraw: polygonsToDraw,
      circlesToDraw: circlesToDraw,
      manual: manual,
      tapPosition: tapPosition,
      regionName: regionName,
      isDownloading: isDownloading,
      mapProvider: mapProvider,
      isActionActivated: isActionActivated,
      userLocation: userLocation,
      selectedMarker: selectedMarker,
    );
  }

  @override
  List<Object?> get props => [
        manual,
        markers,
        polygonsToDraw,
        circlesToDraw,
        tapPosition,
        regionName,
        isDownloading,
        mapProvider,
        isActionActivated,
        selectedMarker,
        userLocation,
      ];
}
