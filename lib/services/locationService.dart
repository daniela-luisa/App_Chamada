import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desabilitado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //Caso um dia precise utilziar :/
  // Stream<Position> getLocationStream({LocationAccuracy accuracy = LocationAccuracy.high, int distanceFilter = 10}) {
  //   return Geolocator.getPositionStream(
  //     locationSettings: LocationSettings(
  //       accuracy: accuracy,
  //       distanceFilter: distanceFilter,
  //     ),
  //   );
  // }
}
