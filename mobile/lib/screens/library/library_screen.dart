import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedView = 'list';
  String _selectedFilter = 'all';
  String _sortOrder = 'newest'; // newest or oldest
  final TextEditingController _searchController = TextEditingController();

  final List<ResourceCard> _resources = [
    // Demo observation cards from the workflow
    ResourceCard(
      id: '1',
      title: 'Identifying Variegated Leaves - Veteran Knowledge',
      description: 'Record learned from veteran farmers that pale leaf color is not a disease but wind sunburn',
      category: 'observation',
      date: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'assets/images/leaf_observation.jpg',
      location: const LatLng(35.6762, 139.6503),
      source: 'Veteran Farmer - Mr. Tanaka',
      confidence: 0.95,
      tags: ['Variegation', 'Sunburn', 'Wind Damage'],
    ),
    ResourceCard(
      id: '2',
      title: 'Manual Soil Moisture Check Method',
      description: 'Record of traditional method checking soil moisture by squeezing with hand',
      category: 'observation',
      date: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'assets/images/soil_check.jpg',
      location: const LatLng(35.6762, 139.6503),
      source: 'Veteran Farmer - Mr. Tanaka',
      confidence: 0.98,
      tags: ['Soil', 'Moisture', 'Manual Check'],
    ),
    ResourceCard(
      id: '3',
      title: 'Practice on My Farm - Rediscovering Variegated Leaves',
      description: 'AI advisor confirmed similar variegation pattern by matching with previous records',
      category: 'ai_analysis',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
      imageUrl: 'assets/images/my_field_observation.jpg',
      location: const LatLng(35.6785, 139.6520),
      source: 'AI Advisor - My Farm',
      confidence: 0.92,
      tags: ['Variegation', 'Similar Case', 'AI Analysis'],
    ),
    ResourceCard(
      id: '4',
      title: 'Crop Disease Identification Guide',
      description: 'Visual guide for identifying common crop diseases and pests',
      category: 'reference',
      date: DateTime.now().subtract(const Duration(days: 20)),
      imageUrl: 'assets/images/disease_guide.jpg',
      location: const LatLng(35.6895, 139.6917),
      source: 'Agricultural Technology Center',
      confidence: 1.0,
      tags: ['Disease', 'Pest', 'Guide'],
    ),
  ];

  List<ResourceCard> get _filteredResources {
    var filtered = _resources;
    
    // Apply category filter (veteran/myfarm/all)
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) {
        if (_selectedFilter == 'veteran') {
          return r.source?.contains('Veteran') ?? false;
        } else if (_selectedFilter == 'myfarm') {
          return (r.source?.contains('My Farm') ?? false) || (r.source?.contains('AI') ?? false);
        }
        return true;
      }).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        r.description.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      if (_sortOrder == 'newest') {
        return b.date.compareTo(a.date);
      } else {
        return a.date.compareTo(b.date);
      }
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
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
          // Demo Flow Success Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Knowledge Accumulation Complete!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Observation records have been generated from veteran farmer knowledge and AI analysis',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/ai-advisor');
                    },
                    icon: const Icon(Icons.psychology),
                    label: const Text('Consult AI Partner Kei'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
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
                Row(
                  children: [
                    // Source filter
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            _buildFilterChip('Veteran', 'veteran'),
                            _buildFilterChip('My Farm', 'myfarm'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort order dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        items: const [
                          DropdownMenuItem(value: 'newest', child: Text('Newest First', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 'oldest', child: Text('Oldest First', style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortOrder = value!;
                          });
                        },
                      ),
                    ),
                  ],
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
      case 'observation':
        return Icons.visibility;
      case 'ai_analysis':
        return Icons.psychology;
      case 'reference':
        return Icons.library_books;
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
      case 'observation':
        return Colors.green[100]!;
      case 'ai_analysis':
        return Colors.purple[100]!;
      case 'reference':
        return Colors.blue[100]!;
      case 'pest':
        return Colors.orange[100]!;
      case 'disease':
        return Colors.red[100]!;
      case 'soil':
        return Colors.brown[100]!;
      case 'irrigation':
        return Colors.cyan[100]!;
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
  final String? source;
  final double? confidence;
  final List<String>? tags;

  ResourceCard({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.location,
    this.source,
    this.confidence,
    this.tags,
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