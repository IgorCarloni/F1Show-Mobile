import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/f1_api.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
    with SingleTickerProviderStateMixin {
  static final int _currentYear = DateTime.now().year;
  static final List<String> _years = List.generate(
    _currentYear - 1949,
    (i) => (_currentYear - i).toString(),
  );

  String _year = 'current';
  late TabController _tabController;
  Future<StandingsList<DriverStanding>>? _driversFuture;
  Future<StandingsList<ConstructorStanding>>? _constructorsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    AnalyticsService.logScreenView('standings');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _driversFuture = F1ApiService.getDriverStandings(_year);
      _constructorsFuture = F1ApiService.getConstructorStandings(_year);
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Year selector
          Container(
            color: F1Theme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text('Temporada:',
                    style: TextStyle(
                        color: F1Theme.textSecondary, fontSize: 14)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: F1Theme.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: F1Theme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _year,
                        dropdownColor: F1Theme.surface,
                        style: const TextStyle(
                            color: F1Theme.textPrimary, fontSize: 15),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'current',
                            child: Text('Atual ($_currentYear)'),
                          ),
                          ..._years.map((y) =>
                              DropdownMenuItem(value: y, child: Text(y))),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            AnalyticsService.logSeasonSelect(v);
                            setState(() => _year = v);
                            _load();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: F1Theme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: F1Theme.red,
              labelColor: F1Theme.textPrimary,
              unselectedLabelColor: F1Theme.textMuted,
              tabs: const [
                Tab(text: '🧑‍✈️ Pilotos'),
                Tab(text: '🏭 Construtores'),
              ],
            ),
          ),
          const Divider(height: 1, color: F1Theme.border),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DriversTab(future: _driversFuture),
                _ConstructorsTab(future: _constructorsFuture),
              ],
            ),
          ),
        ],
      );
}

class _DriversTab extends StatelessWidget {
  final Future<StandingsList<DriverStanding>>? future;
  const _DriversTab({required this.future});

  @override
  Widget build(BuildContext context) => FutureBuilder<StandingsList<DriverStanding>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) return ErrorWidget2(message: snap.error.toString());
          final list = snap.data;
          if (list == null || list.standings.isEmpty) {
            return const Center(
              child: Text('Sem dados para este ano.',
                  style: TextStyle(color: F1Theme.textMuted)),
            );
          }
          final leaderPts = double.tryParse(list.standings[0].points) ?? 1;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LeaderBanner(
                label: '🏆 Líder',
                name: list.standings[0].driver.fullName,
                points: list.standings[0].points,
              ),
              const SizedBox(height: 12),
              ...list.standings.map((s) {
                final pos = int.tryParse(s.position) ?? 99;
                final pts = double.tryParse(s.points) ?? 0;
                final gap = leaderPts - pts;
                return GestureDetector(
                  onTap: () {
                    AnalyticsService.logDriverView(
                        s.driver.id, s.driver.fullName);
                    context.go('/driver/${s.driver.id}');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: F1Theme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: pos <= 3
                            ? const BorderSide(color: F1Theme.red, width: 3)
                            : const BorderSide(color: F1Theme.border),
                        top: const BorderSide(color: F1Theme.border),
                        right: const BorderSide(color: F1Theme.border),
                        bottom: const BorderSide(color: F1Theme.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        MedalBadge(position: pos),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(s.driver.fullName,
                                      style: const TextStyle(
                                          color: F1Theme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  if (s.driver.code != null) ...[
                                    const SizedBox(width: 6),
                                    Text(s.driver.code!,
                                        style: const TextStyle(
                                            color: F1Theme.textMuted,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                              Text(
                                s.constructors.isNotEmpty
                                    ? s.constructors[0].name
                                    : '',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              PointsBar(fraction: pts / leaderPts),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${pts.toInt()}',
                              style: const TextStyle(
                                  color: F1Theme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            ),
                            Text('pts',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 11)),
                            if (gap > 0)
                              Text('−${gap.toInt()}',
                                  style: const TextStyle(
                                      color: F1Theme.textMuted, fontSize: 11)),
                            WinsBadge(wins: int.tryParse(s.wins) ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      );
}

class _ConstructorsTab extends StatelessWidget {
  final Future<StandingsList<ConstructorStanding>>? future;
  const _ConstructorsTab({required this.future});

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<StandingsList<ConstructorStanding>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) return ErrorWidget2(message: snap.error.toString());
          final list = snap.data;
          if (list == null || list.standings.isEmpty) {
            return const Center(
              child: Text('Sem dados para este ano.',
                  style: TextStyle(color: F1Theme.textMuted)),
            );
          }
          final leaderPts = double.tryParse(list.standings[0].points) ?? 1;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LeaderBanner(
                label: '🏆 Líder',
                name: list.standings[0].constructor.name,
                points: list.standings[0].points,
              ),
              const SizedBox(height: 12),
              ...list.standings.map((s) {
                final pos = int.tryParse(s.position) ?? 99;
                final pts = double.tryParse(s.points) ?? 0;
                final gap = leaderPts - pts;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: F1Theme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: pos <= 3
                          ? const BorderSide(color: F1Theme.red, width: 3)
                          : const BorderSide(color: F1Theme.border),
                      top: const BorderSide(color: F1Theme.border),
                      right: const BorderSide(color: F1Theme.border),
                      bottom: const BorderSide(color: F1Theme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      MedalBadge(position: pos),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.constructor.name,
                                style: const TextStyle(
                                    color: F1Theme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(s.constructor.nationality ?? '',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 12)),
                            const SizedBox(height: 6),
                            PointsBar(fraction: pts / leaderPts),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${pts.toInt()}',
                            style: const TextStyle(
                                color: F1Theme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          Text('pts',
                              style: const TextStyle(
                                  color: F1Theme.textMuted, fontSize: 11)),
                          if (gap > 0)
                            Text('−${gap.toInt()}',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 11)),
                          WinsBadge(wins: int.tryParse(s.wins) ?? 0),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      );
}

class _LeaderBanner extends StatelessWidget {
  final String label;
  final String name;
  final String points;
  const _LeaderBanner(
      {required this.label, required this.name, required this.points});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [F1Theme.surface, Color(0xFF2A1A1A)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: F1Theme.red),
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: F1Theme.textSecondary, fontSize: 13)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      color: F1Theme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
            Text('$points pts',
                style: const TextStyle(
                    color: F1Theme.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      );
}
