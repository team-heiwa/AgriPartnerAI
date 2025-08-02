import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportType = 'field_inspection';
  DateTime _selectedDateRange = DateTime.now();

  final List<Report> _recentReports = [
    Report(
      id: '1',
      title: 'Weekly Field Inspection Report',
      type: 'field_inspection',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      summary: 'Overall field health is good. Minor pest activity detected in sector B.',
    ),
    Report(
      id: '2',
      title: 'Pest Management Report',
      type: 'pest_management',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'completed',
      summary: 'Pest control measures applied successfully. Follow-up needed in 2 weeks.',
    ),
    Report(
      id: '3',
      title: 'Irrigation System Analysis',
      type: 'irrigation',
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: 'completed',
      summary: 'System efficiency at 92%. Recommended maintenance for valve 3.',
    ),
    Report(
      id: '4',
      title: 'Monthly Crop Yield Report',
      type: 'yield',
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: 'draft',
      summary: 'Projected yield increase of 15% compared to last month.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate'),
            Tab(text: 'History'),
            Tab(text: 'Templates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(),
          _buildHistoryTab(),
          _buildTemplatesTab(),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate New Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Report Type Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'field_inspection',
                        child: Text('Field Inspection Report'),
                      ),
                      DropdownMenuItem(
                        value: 'pest_management',
                        child: Text('Pest Management Report'),
                      ),
                      DropdownMenuItem(
                        value: 'irrigation',
                        child: Text('Irrigation Analysis'),
                      ),
                      DropdownMenuItem(
                        value: 'yield',
                        child: Text('Crop Yield Report'),
                      ),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom Report'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReportType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Date Range Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Select Date Range'),
                          onPressed: _selectDateRange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_formatDateRange()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Additional Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Include in Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Photos & Images'),
                    value: true,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Drone Footage Analysis'),
                    value: true,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Weather Data'),
                    value: false,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Historical Comparisons'),
                    value: true,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Generate Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Report'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _generateReport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentReports.length,
      itemBuilder: (context, index) {
        final report = _recentReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getReportColor(report.type),
              child: Icon(
                _getReportIcon(report.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              report.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(report.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDate(report.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(
                        report.status.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: report.status == 'completed' 
                          ? Colors.green[100] 
                          : Colors.orange[100],
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'export', child: Text('Export')),
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (value) => _handleReportAction(value, report),
            ),
            onTap: () => _viewReport(report),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesTab() {
    final templates = [
      {'name': 'Weekly Field Inspection', 'icon': Icons.search, 'color': Colors.blue},
      {'name': 'Pest Management Summary', 'icon': Icons.bug_report, 'color': Colors.orange},
      {'name': 'Irrigation Efficiency', 'icon': Icons.water_drop, 'color': Colors.cyan},
      {'name': 'Monthly Yield Analysis', 'icon': Icons.trending_up, 'color': Colors.green},
      {'name': 'Soil Health Report', 'icon': Icons.terrain, 'color': Colors.brown},
      {'name': 'Weather Impact Assessment', 'icon': Icons.cloud, 'color': Colors.grey},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Card(
          child: InkWell(
            onTap: () => _useTemplate(template['name'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  template['icon'] as IconData,
                  size: 48,
                  color: template['color'] as Color,
                ),
                const SizedBox(height: 12),
                Text(
                  template['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getReportColor(String type) {
    switch (type) {
      case 'field_inspection':
        return Colors.blue;
      case 'pest_management':
        return Colors.orange;
      case 'irrigation':
        return Colors.cyan;
      case 'yield':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'field_inspection':
        return Icons.search;
      case 'pest_management':
        return Icons.bug_report;
      case 'irrigation':
        return Icons.water_drop;
      case 'yield':
        return Icons.trending_up;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateRange() {
    return '${_formatDate(_selectedDateRange)} - ${_formatDate(DateTime.now())}';
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedDateRange,
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked.start;
      });
    }
  }

  void _generateReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Generating report...'),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report generated successfully!'),
        ),
      );
      _tabController.animateTo(1);
    });
  }

  void _handleReportAction(String action, Report report) {
    switch (action) {
      case 'view':
        _viewReport(report);
        break;
      case 'export':
        _exportReport(report);
        break;
      case 'share':
        _shareReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _viewReport(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportViewScreen(report: report),
      ),
    );
  }

  void _exportReport(Report report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Report As',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Document'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image (PNG)'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as PNG...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareReport(Report report) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening share dialog...')),
    );
  }

  void _deleteReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _recentReports.removeWhere((r) => r.id == report.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _useTemplate(String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Using template: $templateName')),
    );
    _tabController.animateTo(0);
  }
}

class Report {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final String status;
  final String summary;

  Report({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.status,
    required this.summary,
  });
}

class ReportViewScreen extends StatelessWidget {
  final Report report;

  const ReportViewScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Generated on ${_formatDate(report.date)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Executive Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(report.summary),
            const SizedBox(height: 24),
            // Add more report sections here
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}