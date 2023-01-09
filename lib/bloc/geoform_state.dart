part of 'geoform_bloc.dart';

enum MapProvider { openStreetMap, vectorProvider, customProvider }

class GeoformState extends Equatable {
  const GeoformState._({
    required this.context,
    required this.mapController,
    required this.animationController,
    this.currentMapPosition,
    this.markers = const [],
    this.manual = false,
    this.tapPosition,
    this.regionName,
    this.isDownloading = false,
    this.mapProvider = MapProvider.openStreetMap,
    this.isActionActivated = false,
  });

  GeoformState.initial({
    String? regionName,
    MapProvider? mapProvider,
    LatLng? initialPosition,
    required AnimationController animationController,
  }) : this._(
          context: GeoformContext(
            currentUserPosition: LatLng(0.01, 0.01),
            currentMapPosition: LatLng(0.01, 0.01),
          ),
          animationController: animationController,
          mapController: MapController(),
          currentMapPosition: initialPosition ?? LatLng(50, 50),
          regionName: regionName,
          mapProvider: mapProvider ?? MapProvider.openStreetMap,
        );

  final GeoformContext context;
  final MapController mapController;
  final AnimationController animationController;
  final LatLng? currentMapPosition;
  final List<FastMarker> markers;
  final bool manual;
  final TapPosition? tapPosition;
  final String? regionName;
  final bool isDownloading;
  final MapProvider mapProvider;
  final bool isActionActivated;

  GeoformState copyWith({
    GeoformContext? context,
    MapController? mapController,
    AnimationController? animationController,
    LatLng? currentMapPosition,
    List<FastMarker>? markers,
    bool? manual,
    TapPosition? tapPosition,
    String? regionName,
    bool? isDownloading,
    MapProvider? mapProvider,
    bool? isActionActivated,
  }) {
    return GeoformState._(
      context: context ?? this.context,
      mapController: mapController ?? this.mapController,
      animationController: animationController ?? this.animationController,
      currentMapPosition: currentMapPosition ?? this.currentMapPosition,
      markers: markers ?? this.markers,
      manual: manual ?? this.manual,
      tapPosition: tapPosition ?? this.tapPosition,
      regionName: regionName ?? this.regionName,
      isDownloading: isDownloading ?? this.isDownloading,
      mapProvider: mapProvider ?? this.mapProvider,
      isActionActivated: isActionActivated ?? this.isActionActivated,
    );
  }

  @override
  List<Object?> get props => [
        manual,
        mapController,
        animationController,
        currentMapPosition,
        markers,
        context,
        tapPosition,
        regionName,
        isDownloading,
        mapProvider,
        isActionActivated,
      ];
}
