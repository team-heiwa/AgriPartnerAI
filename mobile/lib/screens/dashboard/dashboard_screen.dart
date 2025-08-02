import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/dashboard/feature_card.dart';
import '../../widgets/dashboard/risk_card.dart';
import '../../widgets/dashboard/live_map_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダッシュボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => context.push('/visit-recorder'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  RiskCard(
                    type: 'pest',
                    score: 0.66,
                    title: '害虫リスク',
                    icon: '🐛',
                    onTap: () => context.push('/actions'),
                  ),
                  RiskCard(
                    type: 'disease',
                    score: 0.72,
                    title: '病気リスク',
                    icon: '🍂',
                    onTap: () => context.push('/actions'),
                  ),
                  RiskCard(
                    type: 'environment',
                    score: 0.42,
                    title: '環境リスク',
                    icon: '🌦️',
                    onTap: () => context.push('/reports'),
                  ),
                  RiskCard(
                    type: 'health',
                    score: 0.28,
                    title: '総合健康度',
                    icon: '🌱',
                    onTap: () => context.push('/reports'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Live Map
              const SizedBox(
                height: 400,
                child: LiveMapWidget(),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.flight,
                    label: 'Drone Ops',
                    color: Colors.blue,
                    route: '/drone',
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.library_books,
                    label: 'Library',
                    color: Colors.teal,
                    route: '/library',
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.check_circle,
                    label: 'Actions',
                    color: Colors.orange,
                    route: '/actions',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'John Farmer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'john.farmer@agripartner.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Visit Recorder'),
            onTap: () {
              Navigator.pop(context);
              context.push('/visit-recorder');
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Actions'),
            onTap: () {
              Navigator.pop(context);
              context.push('/actions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('Drone Operations'),
            onTap: () {
              Navigator.pop(context);
              context.push('/drone');
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Library'),
            onTap: () {
              Navigator.pop(context);
              context.push('/library');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              context.push('/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Live Map'),
            onTap: () {
              Navigator.pop(context);
              context.push('/map');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}