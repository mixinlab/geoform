import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoform/geoform.dart';
import 'package:geoform/geoform_markers.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

part 'geoform_event.dart';
part 'geoform_state.dart';

class GeoformBloc extends Bloc<GeoformEvent, GeoformState> {
  GeoformBloc({
    String? regionName,
    MapProvider? mapProvider,
  }) : super(GeoformState.initial(
          regionName: regionName,
          mapProvider: mapProvider,
        )) {
    on<ManualChanged>(_onManualChanged);
    on<GeoformContextUpdated>(_onGeoformContextUpdated);
    on<GeoformOnTap>(_onGeoformOnTap);
    on<AddRegion>(_onAddRegion);
  }

  Future<void> _onAddRegion(
    AddRegion event,
    Emitter<GeoformState> emit,
  ) async {
    if (event.region == null) {
      return;
    }
    final StoreDirectory _instance = FMTC.instance(state.regionName ?? '');
    if (!_instance.manage.ready) {
      await _instance.manage.createAsync();
      emit(state.copyWith(isDownloading: true));
      final downloadableRegion = event.region!;
      final download =
          _instance.download.startForeground(region: downloadableRegion);
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
}
