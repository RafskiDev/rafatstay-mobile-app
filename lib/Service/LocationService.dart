import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'ApiService.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiService _api = ApiService();
  Position? _lastPosition;

  // استدعيها في main.dart أو عند تسجيل الدخول
  Future<void> init(BuildContext context) async {
    await _requestPermission();
    await _sendCurrentLocation(context);
    _startTracking(context);
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> _sendCurrentLocation(BuildContext context) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateLocation(position, context);
    } catch (e) {
      print("LocationService error: $e");
    }
  }

  void _startTracking(BuildContext context) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 500, // كل 500 متر يرسل طلب
      ),
    ).listen((Position position) {
      _updateLocation(position, context);
    });
  }

  Future<void> _updateLocation(Position position, BuildContext context) async {
    // تجنب إرسال نفس الموقع مرتين
    if (_lastPosition != null &&
        _lastPosition!.latitude == position.latitude &&
        _lastPosition!.longitude == position.longitude) return;

    _lastPosition = position;

    await _api.post(
      "v1/auth/preferences",
      {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      context,
    );
  }
}