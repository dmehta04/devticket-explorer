import '../config/app_config.dart';

class UserPosition {
  final double latitude;
  final double longitude;

  UserPosition({required this.latitude, required this.longitude});
}

class LocationService {
  /// Returns the user's current location.
  /// For now returns the default location (Frankfurt).
  /// Replace with actual GPS once the Android toolchain is updated.
  Future<UserPosition?> getCurrentLocation() async {
    return UserPosition(
      latitude: AppConfig.defaultLat,
      longitude: AppConfig.defaultLng,
    );
  }
}
