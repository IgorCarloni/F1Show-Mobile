import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/f1_api.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<Race> _future;

  @override
  void initState() {
    super.initState();
    _future = F1ApiService.getLastRace();
    AnalyticsService.logScreenView('results');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Race>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) {
            return ErrorWidget2(message: snap.error.toString());
          }
          final race = snap.data!;
          return RefreshIndicator(
            color: F1Theme.red,
            onRefresh: () async {
              setState(() => _future = F1ApiService.getLastRace());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  race.name,
                  style: const TextStyle(
                    color: F1Theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${race.circuit.circuitInfo}  •  ${race.date}',
                  style: const TextStyle(
                      color: F1Theme.textSecondary, fontSize: 13),
                ),
                Text(
                  'Rodada ${race.round}',
                  style:
                      const TextStyle(color: F1Theme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ...race.results.map((r) => _ResultRow(result: r, race: race)),
              ],
            ),
          );
        },
      );
}

class _ResultRow extends StatelessWidget {
  final RaceResult result;
  final Race race;
  const _ResultRow({required this.result, required this.race});

  @override
  Widget build(BuildContext context) {
    final pos = int.tryParse(result.position) ?? 99;
    return GestureDetector(
      onTap: () {
        AnalyticsService.logDriverView(
            result.driver.id, result.driver.fullName);
        context.go('/driver/${result.driver.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              width: 28,
              child: Text(
                result.position,
                style: const TextStyle(
                  color: F1Theme.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        result.driver.fullName,
                        style: const TextStyle(
                          color: F1Theme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (result.driver.code != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          result.driver.code!,
                          style: const TextStyle(
                              color: F1Theme.textMuted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    result.constructor.name,
                    style: const TextStyle(
                        color: F1Theme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  result.time ?? result.status,
                  style: const TextStyle(
                      color: F1Theme.textSecondary, fontSize: 12),
                ),
                Text(
                  '${result.points} pts',
                  style: const TextStyle(
                    color: F1Theme.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on Circuit {
  String get circuitInfo => '$locality, $country';
}
