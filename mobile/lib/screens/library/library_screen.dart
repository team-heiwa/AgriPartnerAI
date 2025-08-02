import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedView = 'list';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<ResourceCard> _resources = [
    ResourceCard(
      id: '1',
      title: 'Pest Management Guide',
      description: 'Comprehensive guide for identifying and managing common agricultural pests',
      category: 'pest',
      date: DateTime.now().subtract(const Duration(days: 5)),
      imageUrl: 'assets/images/pest_guide.jpg',
      location: const LatLng(35.6762, 139.6503),
    ),
    ResourceCard(
      id: '2',
      title: 'Irrigation Best Practices',
      description: 'Efficient water management techniques for sustainable farming',
      category: 'irrigation',
      date: DateTime.now().subtract(const Duration(days: 10)),
      imageUrl: 'assets/images/irrigation.jpg',
      location: const LatLng(35.6812, 139.7671),
    ),
    ResourceCard(
      id: '3',
      title: 'Soil Health Assessment',
      description: 'Methods for evaluating and improving soil quality',
      category: 'soil',
      date: DateTime.now().subtract(const Duration(days: 15)),
      imageUrl: 'assets/images/soil.jpg',
      location: const LatLng(35.6585, 139.7454),
    ),
    ResourceCard(
      id: '4',
      title: 'Crop Disease Identification',
      description: 'Visual guide to common crop diseases and treatment options',
      category: 'disease',
      date: DateTime.now().subtract(const Duration(days: 20)),
      imageUrl: 'assets/images/disease.jpg',
      location: const LatLng(35.6895, 139.6917),
    ),
  ];

  List<ResourceCard> get _filteredResources {
    var filtered = _resources;
    
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.category == _selectedFilter).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        r.description.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_selectedView == 'list' ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'list' ? 'map' : 'list';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddResourceDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Pest', 'pest'),
                      _buildFilterChip('Disease', 'disease'),
                      _buildFilterChip('Soil', 'soil'),
                      _buildFilterChip('Irrigation', 'irrigation'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content View
          Expanded(
            child: _selectedView == 'list' ? _buildListView() : _buildMapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredResources.length,
      itemBuilder: (context, index) {
        final resource = _filteredResources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showResourceDetail(resource),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(resource.category),
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              resource.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              resource.category.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getCategoryColor(resource.category),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resource.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDate(resource.date),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(35.6762, 139.6503),
        zoom: 12,
      ),
      markers: _filteredResources.map((resource) {
        return Marker(
          markerId: MarkerId(resource.id),
          position: resource.location,
          infoWindow: InfoWindow(
            title: resource.title,
            snippet: resource.category,
            onTap: () => _showResourceDetail(resource),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getCategoryHue(resource.category),
          ),
        );
      }).toSet(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pest':
        return Icons.bug_report;
      case 'disease':
        return Icons.coronavirus;
      case 'soil':
        return Icons.terrain;
      case 'irrigation':
        return Icons.water_drop;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pest':
        return Colors.orange[100]!;
      case 'disease':
        return Colors.red[100]!;
      case 'soil':
        return Colors.brown[100]!;
      case 'irrigation':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  double _getCategoryHue(String category) {
    switch (category) {
      case 'pest':
        return BitmapDescriptor.hueOrange;
      case 'disease':
        return BitmapDescriptor.hueRed;
      case 'soil':
        return BitmapDescriptor.hueMagenta;
      case 'irrigation':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueGreen;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showResourceDetail(ResourceCard resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailScreen(resource: resource),
      ),
    );
  }

  void _showAddResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Resource'),
        content: SingleChildScrollView(
          child: Column(
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
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pest', child: Text('Pest')),
                  DropdownMenuItem(value: 'disease', child: Text('Disease')),
                  DropdownMenuItem(value: 'soil', child: Text('Soil')),
                  DropdownMenuItem(value: 'irrigation', child: Text('Irrigation')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
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
                const SnackBar(content: Text('Resource added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class ResourceCard {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String imageUrl;
  final LatLng location;

  ResourceCard({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.location,
  });
}

class ResourceDetailScreen extends StatelessWidget {
  final ResourceCard resource;

  const ResourceDetailScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(resource.category.toUpperCase()),
                    backgroundColor: Colors.blue[100],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    resource.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add more detailed content here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}