// Maps_riverpod.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SafeLatLng {
  static const LatLng fallback = LatLng(36.1901, 44.0093);

  static bool isValid(double? lat, double? lng) {
    return lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat.abs() <= 90 &&
        lng.abs() <= 180;
  }

  static bool isValidPoint(LatLng? p) {
    return p != null &&
        p.latitude.isFinite &&
        p.longitude.isFinite &&
        p.latitude.abs() <= 90 &&
        p.longitude.abs() <= 180;
  }

  static LatLng from(double? lat, double? lng) {
    if (!isValid(lat, lng)) return fallback;
    return LatLng(lat!, lng!);
  }

  static LatLng fromLatLng(LatLng? p) {
    if (!isValidPoint(p)) return fallback;
    return p!;
  }

  static List<LatLng> cleanList(List<LatLng> list) {
    return list.where(isValidPoint).toList();
  }
}

class MapsState {
  final List<LatLng> routePoints;
  final bool isLoading;
  final LatLng? myLocation;
  final String? error;
  final double? duration;
  final double? distance;
  const MapsState({
    this.routePoints = const [],
    this.isLoading = false,
    this.myLocation,
    this.error,
    this.duration,
    this.distance,
  });

  MapsState copyWith({
    List<LatLng>? routePoints,
    bool? isLoading,
    LatLng? myLocation,
    String? error,
    double? duration,
    double? distance,
  }) {
    return MapsState(
      routePoints: routePoints ?? this.routePoints,
      isLoading: isLoading ?? this.isLoading,
      myLocation: myLocation ?? this.myLocation,
      error: error ?? this.error,           // ← إصلاح bug الـ error
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
    );
  }
}

class MapsNotifier extends Notifier<MapsState> {
  StreamSubscription<Position>? _positionStream;

  Function(LatLng)? onMoveCamera;
  @override
  MapsState build() {
    showCard = false;
    ref.notifyListeners();
    return const MapsState();
  }

  bool showCard = false;
  Future<void> fetchRoute({
    required double restaurantLat,
    required double restaurantLng,
  }) async {
    state = state.copyWith(isLoading: true, error: null, routePoints: []);

    try {
      if (!SafeLatLng.isValid(restaurantLat, restaurantLng)) {
        throw Exception("Invalid restaurant coordinates");
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location service disabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied forever");
      }
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        throw Exception("Invalid current location");
      }

      final myLocation = LatLng(position.latitude, position.longitude);

      final url =
          'http://router.project-osrm.org/route/v1/driving/'
          '${position.longitude},${position.latitude};'
          '$restaurantLng,$restaurantLat?overview=full&geometries=geojson';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("OSRM request failed (${response.statusCode})");
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid OSRM response");
      }

      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) {
        throw Exception("No route returned");
      }

      final firstRoute = routes.first;
      if (firstRoute is! Map) {
        throw Exception("Invalid route format");
      }

      final geometry = firstRoute['geometry'];
      if (geometry is! Map) {
        throw Exception("Invalid geometry");
      }

      final coordinates = geometry['coordinates'];
      if (coordinates is! List || coordinates.isEmpty) {
        throw Exception("Invalid coordinates");
      }

      final routePoints = <LatLng>[];

      for (final c in coordinates) {
        if (c is List && c.length >= 2) {
          final lng = c[0];
          final lat = c[1];

          if (lng is num && lat is num) {
            final dLat = lat.toDouble();
            final dLng = lng.toDouble();

            if (dLat.isFinite &&
                dLng.isFinite &&
                dLat.abs() <= 90 &&
                dLng.abs() <= 180) {
              routePoints.add(LatLng(dLat, dLng));
            }
          }
        }
      }

      final safeRoute = routePoints.length >= 2
          ? routePoints
          : <LatLng>[
        myLocation,
        LatLng(restaurantLat, restaurantLng),
      ];
      final double durationValue = (firstRoute['duration'] as num? ?? 0).toDouble();
      final double distanceValue = (firstRoute['distance'] as num? ?? 0).toDouble();
      state = state.copyWith(
        isLoading: false,
        routePoints: safeRoute,
        myLocation: myLocation,
        duration: durationValue,
        distance: distanceValue,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        myLocation: SafeLatLng.fallback,
        routePoints: const [],
        error: e.toString(),
      );
    }
  }
  Future<void> startTracking(
      double restaurantLat,
      double restaurantLng,
      ) async {
    _positionStream?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: settings).listen(
              (position) async {
            if (!position.latitude.isFinite || !position.longitude.isFinite) return;
            final myLocation = LatLng(position.latitude, position.longitude);
            state = state.copyWith(myLocation: myLocation);
            onMoveCamera?.call(myLocation);
            await _fetchRouteOnly(
              myLat: position.latitude,
              myLng: position.longitude,
              restaurantLat: restaurantLat,
              restaurantLng: restaurantLng,
            );
          },
        );
  }

  Future<void> _fetchRouteOnly({
    required double myLat,
    required double myLng,
    required double restaurantLat,
    required double restaurantLng,
  }) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/'
          '$myLng,$myLat;'
          '$restaurantLng,$restaurantLat?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);
      final route = data['routes'][0];
      if (route.isNotEmpty) {
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final double durationValue = (route['duration'] as num? ?? 0).toDouble();
        final double distanceValue = (route['distance'] as num? ?? 0).toDouble();
        final routePoints = coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
        state = state.copyWith(routePoints: routePoints, duration: durationValue, distance: distanceValue);
      }
    } catch (_) {}
  }

  void showCards() {
    showCard = !showCard;
    ref.notifyListeners();
  }


}

final mapsProvider =
NotifierProvider<MapsNotifier, MapsState>(MapsNotifier.new);