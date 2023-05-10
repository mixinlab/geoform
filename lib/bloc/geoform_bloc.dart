import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geoform/flutter_map_fast_markers/flutter_map_fast_markers.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform.dart';

part 'geoform_event.dart';
part 'geoform_state.dart';

class GeoformBloc extends Bloc<GeoformEvent, GeoformState> {
  GeoformBloc({
    String? regionName,
    MapProvider? mapProvider,
    LatLng? initialPosition,
    required AnimationController animationController,
  }) : super(GeoformState.initial(
            regionName: regionName,
            mapProvider: mapProvider,
            initialPosition: initialPosition,
            animationController: animationController)) {
    on<ManualChanged>(_onManualChanged);
    on<GeoformContextUpdated>(_onGeoformContextUpdated);
    on<GeoformOnTap>(_onGeoformOnTap);
    on<AddRegion>(_onAddRegion);
    on<ChangeMapPosition>(_onChangeMapPosition);
    on<ChangeMarkers>(_onChangeMarkers);
    on<AddAnimation>(_onAddAnimation);
    on<ChangeActivateAction>(_onActivateAction);

    _mapEventSubscription = state.mapController.mapEventStream.listen(
      (event) => add(
        ChangeMapPosition(
          position: LatLng(
            event.center.latitude,
            event.center.longitude,
          ),
        ),
      ),
    )..pause();
  }

  late StreamSubscription<MapEvent> _mapEventSubscription;

  void _onChangeMapPosition(
      ChangeMapPosition event, Emitter<GeoformState> emit) {
    emit(state.copyWith(currentMapPosition: event.position));
  }

  void _onChangeMarkers(ChangeMarkers event, Emitter<GeoformState> emit) {
    emit(state.copyWith(markers: event.markers));
  }

  void _onAddAnimation(AddAnimation event, Emitter<GeoformState> emit) {
    emit(state.copyWith(animationController: event.controller));
  }

  void _onActivateAction(
      ChangeActivateAction event, Emitter<GeoformState> emit) {
    emit(state.copyWith(isActionActivated: event.isActivated));
  }

  Future<void> _onAddRegion(
    AddRegion event,
    Emitter<GeoformState> emit,
  ) async {
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

  Future<void> _onManualChanged(
    ManualChanged event,
    Emitter<GeoformState> emit,
  ) async {
    emit(state.copyWith(manual: event.manual));
    if (event.manual) {
      _mapEventSubscription.resume();
    } else {
      _mapEventSubscription.pause();
    }
  }

  Future<void> _onGeoformContextUpdated(
    GeoformContextUpdated event,
    Emitter<GeoformState> emit,
  ) async {
    emit(state.copyWith(context: event.context));
  }

  Future<void> _onGeoformOnTap(
    GeoformOnTap event,
    Emitter<GeoformState> emit,
  ) async {
    emit(state.copyWith(tapPosition: event.tapPosition));
  }

  @override
  Future<void> close() {
    _mapEventSubscription.cancel();
    state.animationController.dispose();
    return super.close();
  }
}
