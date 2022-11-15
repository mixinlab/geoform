part of 'geoform_bloc.dart';

enum MapProvider { openStreetMap, vectorProvider, customProvider }

class GeoformState<U extends GeoformMarkerDatum> extends Equatable {
  const GeoformState._({
    this.context,
    this.manual = false,
    this.tapPosition,
    this.regionName,
    this.isDownloading = false,
    this.mapProvider = MapProvider.openStreetMap,
  });

  GeoformState.initial({String? regionName, MapProvider? mapProvider})
      : this._(
          context: GeoformContext(
            currentUserPosition: LatLng(0.01, 0.01),
            currentMapPosition: LatLng(0.01, 0.01),
          ),
          regionName: regionName,
          mapProvider: mapProvider ?? MapProvider.openStreetMap,
        );

  final bool manual;
  final GeoformContext? context;
  final TapPosition? tapPosition;
  final String? regionName;
  final bool isDownloading;
  final MapProvider mapProvider;

  GeoformState copyWith({
    GeoformContext? context,
    bool? manual,
    TapPosition? tapPosition,
    String? regionName,
    bool? isDownloading,
    MapProvider? mapProvider,
  }) {
    return GeoformState._(
      context: context ?? this.context,
      manual: manual ?? this.manual,
      tapPosition: tapPosition ?? this.tapPosition,
      regionName: regionName ?? this.regionName,
      isDownloading: isDownloading ?? this.isDownloading,
      mapProvider: mapProvider ?? this.mapProvider,
    );
  }

  @override
  List<Object?> get props => [
        manual,
        context,
        tapPosition,
        regionName,
        isDownloading,
        mapProvider,
      ];
}
