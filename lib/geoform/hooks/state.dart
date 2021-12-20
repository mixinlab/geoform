import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geoformflutter/geoform/entities.dart';
import 'package:geolocator/geolocator.dart';

useGeoFormState({MapController? mapController1}) {
  final userPosition = useState(Position.fromMap({
    "latitude": -12.04589,
    "longitude": -77.019346,
  }));

  final manualMode = useState(false);
  final mapController = useState(mapController1 ?? MapController());
  final selectedPosition = useState(userPosition.value);
  final selectedFixedPoint = useState<GeoFormFixedPoint?>(null);

  final mapAnimationController = useAnimationController(
    duration: const Duration(milliseconds: 820),
  );
}
