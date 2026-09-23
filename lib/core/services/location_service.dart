import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

abstract class LocationService {
  Future<Position> getCurrentPosition();
  Future<bool> checkAndRequestPermission();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(message: 'Layanan lokasi (GPS) tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
            message: 'Izin akses lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        message:
            'Izin akses lokasi ditolak secara permanen. Harap aktifkan di pengaturan perangkat.',
      );
    }

    return true;
  }

  @override
  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermission();
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw LocationException(message: 'Gagal mendapatkan koordinat GPS: $e');
    }
  }
}
