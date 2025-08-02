import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

class LiveMapWidget extends StatefulWidget {
  const LiveMapWidget({super.key});

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final LatLng _farmCenter = const LatLng(35.6762, 139.6503);

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('alert1'),
        position: const LatLng(35.6762, 139.6503),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Pest Alert',
          snippet: 'High activity detected',
        ),
      ),
      Marker(
        markerId: const MarkerId('drone1'),
        position: const LatLng(35.6785, 139.6545),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Drone Active',
          snippet: 'Scanning field B',
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Map',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 20),
                  onPressed: () {
                    context.push('/map');
                  },
                  tooltip: 'Full View',
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _farmCenter,
                  zoom: 14,
                ),
                mapType: MapType.satellite,
                markers: _markers,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}