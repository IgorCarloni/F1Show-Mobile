import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/f1_api.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class SeasonScreen extends StatefulWidget {
  const SeasonScreen({super.key});

  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  static final int _currentYear = DateTime.now().year;
  static final List<String> _years = List.generate(
    _currentYear - 1949,
    (i) => (_currentYear - i).toString(),
  );

  String _year = DateTime.now().year.toString();
  Future<List<Race>>? _racesFuture;
  Future<Race>? _resultFuture;
  Race? _selectedRace;

  @override
  void initState() {
    super.initState();
    _loadRaces();
    AnalyticsService.logScreenView('season');
  }

  void _loadRaces() {
    setState(() {
      _racesFuture = F1ApiService.getSeasonRaces(_year);
      _resultFuture = null;
      _selectedRace = null;
    });
  }

  void _selectRace(Race race) {
    AnalyticsService.logRaceSelect(race.name);
    setState(() {
      _selectedRace = race;
      _resultFuture =
          F1ApiService.getRaceResult(_year, race.round);
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
                        items: _years
                            .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            AnalyticsService.logSeasonSelect(v);
                            setState(() => _year = v);
                            _loadRaces();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: F1Theme.border),
          Expanded(
            child: _selectedRace == null
                ? _buildRaceList()
                : _buildRaceDetail(),
          ),
        ],
      );

  Widget _buildRaceList() => FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) {
            return ErrorWidget2(message: snap.error.toString());
          }
          final races = snap.data ?? [];
          if (races.isEmpty) {
            return Center(
              child: Text('Sem corridas para $_year',
                  style:
                      const TextStyle(color: F1Theme.textMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: races.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = races[i];
              return F1Card(
                onTap: () => _selectRace(r),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: F1Theme.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'R${r.round}',
                          style: const TextStyle(
                            color: F1Theme.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                color: F1Theme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                          Text(
                            '${r.circuit.locality}, ${r.circuit.country}',
                            style: const TextStyle(
                                color: F1Theme.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(r.date,
                        style: const TextStyle(
                            color: F1Theme.textMuted, fontSize: 12)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right,
                        color: F1Theme.textMuted, size: 18),
                  ],
                ),
              );
            },
          );
        },
      );

  Widget _buildRaceDetail() => FutureBuilder<Race>(
        future: _resultFuture,
        builder: (context, snap) {
          return Column(
            children: [
              // Back bar
              GestureDetector(
                onTap: () => setState(() {
                  _selectedRace = null;
                  _resultFuture = null;
                }),
                child: Container(
                  color: F1Theme.surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios,
                          color: F1Theme.red, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _selectedRace!.name,
                          style: const TextStyle(
                            color: F1Theme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: F1Theme.border),
              Expanded(
                child: snap.connectionState == ConnectionState.waiting
                    ? const LoadingWidget()
                    : snap.hasError
                        ? ErrorWidget2(message: snap.error.toString())
                        : _ResultsList(race: snap.data!),
              ),
            ],
          );
        },
      );
}

class _ResultsList extends StatelessWidget {
  final Race race;
  const _ResultsList({required this.race});

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: race.results.length,
        separatorBuilder: (context, i) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final r = race.results[i];
          final pos = int.tryParse(r.position) ?? 99;
          return GestureDetector(
            onTap: () => context.go('/driver/${r.driver.id}'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  SizedBox(
                    width: 26,
                    child: Text(r.position,
                        style: const TextStyle(
                            color: F1Theme.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.driver.fullName,
                            style: const TextStyle(
                                color: F1Theme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(r.constructor.name,
                            style: const TextStyle(
                                color: F1Theme.textSecondary,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(r.time ?? r.status,
                          style: const TextStyle(
                              color: F1Theme.textSecondary,
                              fontSize: 11)),
                      Text('${r.points} pts',
                          style: const TextStyle(
                              color: F1Theme.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
}
