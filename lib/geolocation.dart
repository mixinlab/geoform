import 'package:geolocator/geolocator.dart';

Future _validateGeolocationPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return Future.value(null);
}

Future<Position> determinePosition() async {
  try {
    await _validateGeolocationPermissions();
  } on Exception catch (e) {
    // logger.e(e);
    print(e);
    return Future.error(e);
  }

  return await Geolocator.getCurrentPosition();
}

Future<Stream<Position>> watchUserPosition() async {
  try {
    await _validateGeolocationPermissions();
  } on Exception catch (e) {
    print(e);
    return Future.error(e);
  }

  // Geolocator.getCurrentPosition()
  return Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best);
}
