import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geoform/flutter_map_fast_markers/src/fast_polygon_layer.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

part 'geoform_event.dart';
part 'geoform_state.dart';

class GeoformBloc<U extends GeoformMarkerDatum>
    extends Bloc<GeoformEvent, GeoformState<U>> {
  GeoformBloc({
    String? regionName,
    MapProvider? mapProvider,
    List<U>? markers,
    List<FastPolygon>? polygonsToDraw,
    List<CircleMarker>? circlesToDraw,
    LatLng? mapPosition,
  }) : super(
          GeoformState<U>._(
            regionName: regionName,
            mapProvider: mapProvider ?? MapProvider.openStreetMap,
            markers: markers ?? [],
            polygonsToDraw: polygonsToDraw ?? [],
            circlesToDraw: circlesToDraw ?? [],
            mapPosition: mapPosition,
          ),
        ) {
    on<ManualChanged>(_onManualChanged);
    on<GeoformOnTap>(_onGeoformOnTap);
    on<AddRegion>(_onAddRegion);
    on<InitLocationService>(_initLocationService);
    on<UpdateMarkers<U>>(_onChangeMarkers);
    on<UpdatePolygons>(_onChangePolygons);
    on<UpdateCircles>(_onChangeCircles);
    on<ChangeActivateAction>(_onActivateAction);
    on<SelectMarker<U>>(_selectDatum);
    on<UpdateMapPosition>(_updateMapPosition);
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  // StreamSubscription? _locationSubscription;

  void _onChangeMarkers(UpdateMarkers<U> event, Emitter<GeoformState<U>> emit) {
    emit(state.copyWith(markers: event.markers));
  }

  void _onChangePolygons(UpdatePolygons event, Emitter<GeoformState<U>> emit) {
    emit(state.copyWith(polygonsToDraw: event.polygons));
  }

  void _onChangeCircles(UpdateCircles event, Emitter<GeoformState<U>> emit) {
    emit(state.copyWith(circlesToDraw: event.circles));
  }

  void _onActivateAction(
      ChangeActivateAction event, Emitter<GeoformState<U>> emit) {
    emit(state.copyWith(isActionActivated: event.isActivated));
  }

  Future<void> _onAddRegion(
      AddRegion event, Emitter<GeoformState<U>> emit) async {
    if (event.region == null) {
      return;
    }
    final StoreDirectory instance = FMTC.instance(state.regionName ?? '');
    if (!instance.manage.ready) {
      await instance.manage.createAsync();
      emit(state.copyWith(isDownloading: true));
      final downloadableRegion = event.region!;
      final download =
          instance.download.startForeground(region: downloadableRegion);
      debugPrint('Download start');
      await emit.forEach(download, onData: (DownloadProgress downloadProgress) {
        debugPrint(
            'Porcentaje ${downloadProgress.percentageProgress}, existing ${downloadProgress.existingTiles}');
        if (downloadProgress.percentageProgress == 100) {
          debugPrint('Complete');
        }
        return state.copyWith(
          isDownloading: downloadProgress.percentageProgress != 100,
        );
      });
    }
  }

  Future<void> _initLocationService(
    InitLocationService event,
    Emitter<GeoformState<U>> emit,
  ) async {
    Position locationData;
    LocationPermission permission;

    final serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    locationData = await _geolocatorPlatform.getCurrentPosition();
    emit(state.copyWith(userLocation: locationData));

    // _locationSubscription =
    //     _geolocatorPlatform.getPositionStream().listen((locationData) async {
    //   // emit(state.copyWith(userLocation: locationData));
    // });
  }

  void _onManualChanged(
    ManualChanged event,
    Emitter<GeoformState<U>> emit,
  ) {
    emit(state.copyWith(manual: event.manual));
  }

  void _onGeoformOnTap(
    GeoformOnTap event,
    Emitter<GeoformState<U>> emit,
  ) async {
    emit(state.copyWith(tapPosition: event.tapPosition));
  }

  void _selectDatum(
    SelectMarker<U> event,
    Emitter<GeoformState<U>> emit,
  ) {
    if (state.manual) {
      add(const ManualChanged(manual: false));
    }
    emit(state.changeMarker(selectedMarker: event.marker));
    add(const ChangeActivateAction(isActivated: false));
  }

  void _updateMapPosition(
    UpdateMapPosition event,
    Emitter<GeoformState<U>> emit,
  ) {
    emit(state.copyWith(mapPosition: event.mapPosition));
  }

  @override
  Future<void> close() {
    // _locationSubscription?.cancel();
    return super.close();
  }
}
