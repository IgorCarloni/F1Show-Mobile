import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/results_screen.dart';
import '../screens/season_screen.dart';
import '../screens/standings_screen.dart';
import '../screens/driver_detail_screen.dart';
import '../theme/app_theme.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/results', builder: (context, state) => const ResultsScreen()),
        GoRoute(path: '/season', builder: (context, state) => const SeasonScreen()),
        GoRoute(path: '/standings', builder: (context, state) => const StandingsScreen()),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/driver/:id',
      builder: (context, state) =>
          DriverDetailScreen(driverId: state.pathParameters['id']!),
    ),
  ],
);

class _TabItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem(this.path, this.label, this.icon, this.activeIcon);
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  static const _tabs = [
    _TabItem('/', 'Início', Icons.home_outlined, Icons.home),
    _TabItem('/results', 'Resultados', Icons.flag_outlined, Icons.flag),
    _TabItem('/season', 'Temporadas', Icons.calendar_month_outlined, Icons.calendar_month),
    _TabItem('/standings', 'Classificação', Icons.leaderboard_outlined, Icons.leaderboard),
  ];

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (i == 0 ? loc == '/' : loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _index(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('F1',
                style: TextStyle(
                    color: F1Theme.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const Text(' Show',
                style: TextStyle(
                    color: F1Theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text(_tabs[idx].label,
                style: const TextStyle(
                    color: F1Theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: F1Theme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => context.go(_tabs[i].path),
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    activeIcon: Icon(t.activeIcon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
