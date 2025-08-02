import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/visit_recorder/visit_recorder_screen.dart';
import 'screens/actions/actions_screen.dart';
import 'screens/drone_ops/drone_ops_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  runApp(const AgriPartnerApp());
}

class AgriPartnerApp extends StatelessWidget {
  const AgriPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'AgriPartner',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/visit-recorder',
      builder: (context, state) => const VisitRecorderScreen(),
    ),
    GoRoute(
      path: '/actions',
      builder: (context, state) => const ActionsScreen(),
    ),
    GoRoute(
      path: '/drone',
      builder: (context, state) => const DroneOpsScreen(),
    ),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);