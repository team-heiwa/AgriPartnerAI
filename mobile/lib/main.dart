import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/visit_recorder/visit_recorder_screen.dart';
import 'screens/actions/actions_screen.dart';
import 'screens/drone_ops/drone_ops_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/voice_test/voice_test_screen.dart';
import 'screens/gemma_test/gemma_test_screen.dart';
import 'screens/gemma_mediapipe_test/gemma_mediapipe_test_screen.dart';
import 'screens/ai_models/ai_models_screen.dart';
import 'screens/coreml_test/coreml_test_screen.dart';
import 'screens/ai_advisor/ai_advisor_screen.dart';

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
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/visit-recorder',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'];
        final title = state.uri.queryParameters['title'];
        return VisitRecorderScreen(mode: mode, title: title);
      },
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
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/voice-test',
      builder: (context, state) => const VoiceTestScreen(),
    ),
    GoRoute(
      path: '/gemma-test',
      builder: (context, state) => const GemmaTestScreen(),
    ),
    GoRoute(
      path: '/gemma-mediapipe-test',
      builder: (context, state) => const GemmaMediaPipeTestScreen(),
    ),
    GoRoute(
      path: '/ai-models',
      builder: (context, state) => const AIModelsScreen(),
    ),
    GoRoute(
      path: '/coreml-test',
      builder: (context, state) => const CoreMLTestScreen(),
    ),
    GoRoute(
      path: '/ai-advisor',
      builder: (context, state) => const AIAdvisorScreen(),
    ),
  ],
);