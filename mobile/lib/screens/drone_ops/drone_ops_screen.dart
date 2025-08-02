import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DroneOpsScreen extends StatefulWidget {
  const DroneOpsScreen({super.key});

  @override
  State<DroneOpsScreen> createState() => _DroneOpsScreenState();
}

class _DroneOpsScreenState extends State<DroneOpsScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isManualControl = false;
  double _droneSpeed = 50.0;
  double _altitude = 30.0;

  final LatLng _initialPosition = const LatLng(35.6762, 139.6503); // Tokyo

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('drone'),
        position: _initialPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Drone Position'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drone Operations'),
        actions: [
          IconButton(
            icon: Icon(_isManualControl ? Icons.gamepad : Icons.route),
            onPressed: () {
              setState(() {
                _isManualControl = !_isManualControl;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map View
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              onTap: _isManualControl ? null : _addWaypoint,
            ),
          ),
          // Control Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: _isManualControl
                  ? _buildManualControls()
                  : _buildRouteControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualControls() {
    return Column(
      children: [
        const Text(
          'Manual Control',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        // Directional Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  iconSize: 40,
                  onPressed: () => _moveDrone('forward'),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 40,
                      onPressed: () => _moveDrone('left'),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      iconSize: 40,
                      onPressed: () => _moveDrone('right'),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 40,
                  onPressed: () => _moveDrone('backward'),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  iconSize: 40,
                  onPressed: () => _adjustAltitude(5),
                ),
                Text('Alt: ${_altitude.toStringAsFixed(0)}m'),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 40,
                  onPressed: () => _adjustAltitude(-5),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Speed Control
        Row(
          children: [
            const Text('Speed:'),
            Expanded(
              child: Slider(
                value: _droneSpeed,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_droneSpeed.toStringAsFixed(0)}%',
                onChanged: (value) {
                  setState(() {
                    _droneSpeed = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteControls() {
    return Column(
      children: [
        const Text(
          'Route Planning',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location),
              label: const Text('Add Waypoint'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap on the map to add waypoints'),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear Route'),
              onPressed: _clearRoute,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Flight Parameters
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildParameter('Flight Speed', '${_droneSpeed.toStringAsFixed(0)} km/h'),
                _buildParameter('Altitude', '${_altitude.toStringAsFixed(0)} m'),
                _buildParameter('Battery', '85%'),
                _buildParameter('Est. Duration', '12 min'),
              ],
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule Flight'),
                onPressed: _scheduleFligh,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Flight'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _startFlight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParameter(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _moveDrone(String direction) {
    // Implement drone movement logic
    print('Moving drone: $direction');
  }

  void _adjustAltitude(double change) {
    setState(() {
      _altitude = (_altitude + change).clamp(10, 120);
    });
  }

  void _addWaypoint(LatLng position) {
    setState(() {
      final markerId = 'waypoint_${_markers.length}';
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Waypoint ${_markers.length}'),
        ),
      );
      
      // Add polyline
      if (_markers.length > 1) {
        final points = _markers.map((m) => m.position).toList();
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    });
  }

  void _clearRoute() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _initializeMarkers();
    });
  }

  void _scheduleFligh() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Flight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateTime.now().toString().split(' ')[0]),
              onTap: () {
                // Show date picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: const Text('10:00 AM'),
              onTap: () {
                // Show time picker
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Flight scheduled successfully')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _startFlight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Flight'),
        content: const Text('Are you sure you want to start the drone flight?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Flight started')),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}