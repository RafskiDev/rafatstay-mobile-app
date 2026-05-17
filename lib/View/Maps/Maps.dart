// Maps.dart
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:rafatstay/Widget/WidgetAppBar.dart';
import '../../Service/LoadingService.dart';
import '../../Widget/ShowLoading.dart';
import '../Booking/Booking.dart';
import '../BottomBar/BottomBar.dart';
import 'Maps_riverpod.dart';
import 'Widget/NavigationInfoCard.dart';
import 'Widget/RouteInfoCard.dart';

class Maps extends ConsumerStatefulWidget {
  final double restaurantLat;
  final double restaurantLng;
  final List<Map<String, dynamic>> data;

  const Maps({
    super.key,
    required this.restaurantLat,
    required this.restaurantLng,
    this.data = const [],
  });

  @override
  ConsumerState<Maps> createState() => _MapsState();
}

class _MapsState extends ConsumerState<Maps> {
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(mapsProvider.notifier);
      print("data: ${widget.data}");

      notifier.fetchRoute(
        restaurantLat: widget.restaurantLat,
        restaurantLng: widget.restaurantLng,
      );

      notifier.startTracking(
        widget.restaurantLat,
        widget.restaurantLng,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapsState = ref.watch(mapsProvider);
    final notifier = ref.read(mapsProvider.notifier);

    notifier.onMoveCamera = (LatLng p) {
      _mapController.move(p, _mapController.camera.zoom);
    };

    final myLocation = SafeLatLng.fromLatLng(mapsState.myLocation);
    final restaurantLocation = SafeLatLng.from(
      widget.restaurantLat,
      widget.restaurantLng,
    );

    final route = SafeLatLng.cleanList(mapsState.routePoints);
    final polylinePoints = route.length >= 2
        ? route
        : <LatLng>[myLocation, restaurantLocation];
    final safePolyline = SafeLatLng.cleanList(polylinePoints);

    final mapKey = ValueKey(
      '${myLocation.latitude},${myLocation.longitude},'
          '${restaurantLocation.latitude},${restaurantLocation.longitude}',
    );

    // ✅ isLoading: صحيح لو المسار ما جاي بعد
    final bool isLoading = mapsState.routePoints.isEmpty;
    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        TextLanguage().GetWord("الخرائط"),
      ),
      body:Stack(
        children: [
          // ── الخريطة دائماً موجودة في الخلف ──
          FlutterMap(
            mapController: _mapController,
            key: mapKey,
            options: MapOptions(
              initialCenter: myLocation,
              initialZoom: 14,
              minZoom: 3,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: safePolyline,
                    color: Themes().GetColor("primary"),
                    strokeWidth: 3,
                    borderColor: Colors.white,
                    borderStrokeWidth: 1,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: restaurantLocation,
                    width: Sizes(context).GetHeight() * 5,
                    height: Sizes(context).GetHeight() * 5,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.data.isNotEmpty &&
                            widget.data.first["NavigationInfoCard"] == true) {
                          notifier.showCards();
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf99BY0LkqMHNICONVbcb_Q6IJbqGFPSIkQg&s",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: myLocation,
                    width: Sizes(context).GetHeight() * 5,
                    height: Sizes(context).GetHeight() * 4,
                    child: SvgPicture.asset(
                      "assets/icon/boy.svg",
                      colorFilter: ColorFilter.mode(
                        Themes().GetColor("textPrimary"),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.data.isNotEmpty &&
                  widget.data.first["RouteInfoCard"] == true)
                Positioned(
                  bottom: Sizes(context).GetHeight() * 3,
                  left: Sizes(context).GetWidth() * 2,
                  right: Sizes(context).GetWidth() * 2,
                  child: RouteInfoCard(
                    id: widget.data.first["id"] ?? "",
                    distance:
                    "${((mapsState.distance ?? 0) / 1000).toStringAsFixed(1)} km",
                    duration: getFormattedTime(mapsState.duration ?? 0),
                    arrivalTime: getArrivalTime(mapsState.duration),
                    onRouteTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomBar(initialIndex: 3)),
                            (route) => false,
                      );
                    },
                    onCloseTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              if (notifier.showCard ||
                  widget.data.isNotEmpty &&
                      widget.data.first["NavigationInfoCard"] == true)
                Positioned(
                  bottom: Sizes(context).GetHeight() * 2,
                  left: Sizes(context).GetWidth() * 2,
                  right: Sizes(context).GetWidth() * 2,
                  child: NavigationInfoCard(
                    distance:
                    "${((mapsState.distance ?? 0) / 1000).toStringAsFixed(1)} km",
                    duration: getFormattedTime(mapsState.duration ?? 0),
                    arrivalTime: getArrivalTime(mapsState.duration),
                    onRouteTap: () {
                      print("تغيير المسار...");
                    },
                    onCloseTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
          // ✅ Loading overlay فوق كل شيء
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   showLoading(),
                   SizedBox(height: Sizes(context).GetHeight()*2),
                     Text(
                      TextLanguage().GetWord("جاري تحميل المسار..."),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String getFormattedTime(double seconds) {
    final int minutes = (seconds / 60).round();
    final int hours = (seconds / 3600).floor();
    final int days = (seconds / 86400).floor();
    if (days > 0) {
      return "$days يوم";
    }
    if (hours > 0) {
      final int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return "$hours ساعة";
      }

      return '$hours ${TextLanguage().GetWord('ساعة')} ${TextLanguage().GetWord('و')} ' '$remainingMinutes' ' ${TextLanguage().GetWord('دقيقة')}';

    }
    return "$minutes دقيقة";
  }
  String getArrivalTime(double? seconds) {
    final now = DateTime.now();
    final arrival = now.add(Duration(seconds: (seconds ?? 0).toInt()));
    final hour = arrival.hour % 12 == 0 ? 12 : arrival.hour % 12;
    final minute = arrival.minute.toString().padLeft(2, '0');
    final period = arrival.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}