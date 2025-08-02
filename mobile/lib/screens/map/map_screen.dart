import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  String _selectedLayer = 'satellite';
  bool _showFieldBoundaries = true;
  bool _showDroneRoutes = false;
  bool _showWeatherOverlay = false;

  final LatLng _farmCenter = const LatLng(35.6762, 139.6503);

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    // Add field markers
    _markers.addAll([
      Marker(
        markerId: const MarkerId('field_a'),
        position: const LatLng(35.6762, 139.6503),
        infoWindow: const InfoWindow(
          title: 'Field A',
          snippet: 'Tomatoes - Health: 85%',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('field_b'),
        position: const LatLng(35.6785, 139.6545),
        infoWindow: const InfoWindow(
          title: 'Field B',
          snippet: 'Corn - Health: 72%',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
      Marker(
        markerId: const MarkerId('field_c'),
        position: const LatLng(35.6740, 139.6480),
        infoWindow: const InfoWindow(
          title: 'Field C',
          snippet: 'Wheat - Health: 91%',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    ]);

    // Add field boundaries
    _polygons.addAll([
      Polygon(
        polygonId: const PolygonId('field_a_boundary'),
        points: const [
          LatLng(35.6762, 139.6503),
          LatLng(35.6772, 139.6513),
          LatLng(35.6762, 139.6523),
          LatLng(35.6752, 139.6513),
        ],
        fillColor: Colors.green.withOpacity(0.3),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
      Polygon(
        polygonId: const PolygonId('field_b_boundary'),
        points: const [
          LatLng(35.6785, 139.6545),
          LatLng(35.6795, 139.6555),
          LatLng(35.6785, 139.6565),
          LatLng(35.6775, 139.6555),
        ],
        fillColor: Colors.yellow.withOpacity(0.3),
        strokeColor: Colors.yellow[700]!,
        strokeWidth: 2,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showLayersDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _farmCenter,
              zoom: 15,
            ),
            mapType: _getMapType(),
            markers: _markers,
            polygons: _showFieldBoundaries ? _polygons : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Status Cards
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusCard(
                    'Active Alerts',
                    '3',
                    Colors.red,
                    Icons.warning,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusCard(
                    'Drones Active',
                    '2',
                    Colors.blue,
                    Icons.flight,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusCard(
                    'Field Health',
                    '82%',
                    Colors.green,
                    Icons.eco,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusCard(
                    'Weather',
                    'Clear',
                    Colors.orange,
                    Icons.wb_sunny,
                  ),
                ],
              ),
            ),
          ),
          // Floating Action Buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'location',
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: _showAddOptionsDialog,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MapType _getMapType() {
    switch (_selectedLayer) {
      case 'satellite':
        return MapType.satellite;
      case 'terrain':
        return MapType.terrain;
      case 'hybrid':
        return MapType.hybrid;
      default:
        return MapType.normal;
    }
  }

  void _showLayersDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Layers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Standard'),
              value: 'standard',
              groupValue: _selectedLayer,
              onChanged: (value) {
                setState(() {
                  _selectedLayer = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Satellite'),
              value: 'satellite',
              groupValue: _selectedLayer,
              onChanged: (value) {
                setState(() {
                  _selectedLayer = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Terrain'),
              value: 'terrain',
              groupValue: _selectedLayer,
              onChanged: (value) {
                setState(() {
                  _selectedLayer = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Hybrid'),
              value: 'hybrid',
              groupValue: _selectedLayer,
              onChanged: (value) {
                setState(() {
                  _selectedLayer = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Map Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Field Boundaries'),
                value: _showFieldBoundaries,
                onChanged: (value) {
                  setState(() {
                    _showFieldBoundaries = value;
                  });
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Drone Routes'),
                value: _showDroneRoutes,
                onChanged: (value) {
                  setState(() {
                    _showDroneRoutes = value;
                  });
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Weather Overlay'),
                value: _showWeatherOverlay,
                onChanged: (value) {
                  setState(() {
                    _showWeatherOverlay = value;
                  });
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add to Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Mark Location'),
              onTap: () {
                Navigator.pop(context);
                _addMarker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop_free),
              title: const Text('Draw Field Boundary'),
              onTap: () {
                Navigator.pop(context);
                _drawFieldBoundary();
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Plan Drone Route'),
              onTap: () {
                Navigator.pop(context);
                _planDroneRoute();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Add Field Note'),
              onTap: () {
                Navigator.pop(context);
                _addFieldNote();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToMyLocation() {
    // In a real app, this would get the user's current location
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_farmCenter),
    );
  }

  void _addMarker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap on the map to add a marker')),
    );
  }

  void _drawFieldBoundary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap multiple points to draw a boundary')),
    );
  }

  void _planDroneRoute() {
    context.push('/drone');
  }

  void _addFieldNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Field Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
                const SnackBar(content: Text('Note added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}