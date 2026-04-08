import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/f1_api.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class DriverDetailScreen extends StatefulWidget {
  final String driverId;
  const DriverDetailScreen({super.key, required this.driverId});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  late Future<List<Race>> _future;
  late Future<Race> _lastRaceFuture;

  @override
  void initState() {
    super.initState();
    _future = F1ApiService.getDriverHistory(widget.driverId);
    _lastRaceFuture = F1ApiService.getLastRace();
    AnalyticsService.logScreenView('driver_detail');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
        future: Future.wait([_future, _lastRaceFuture]),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) {
            return ErrorWidget2(message: snap.error.toString());
          }
          final history = snap.data![0] as List<Race>;
          final lastRace = snap.data![1] as Race;
          final driverResult = lastRace.results
              .where((r) => r.driver.id == widget.driverId)
              .firstOrNull;
          final driver = driverResult?.driver ??
              (history.isNotEmpty
                  ? history[0].results[0].driver
                  : null);

          if (driver == null) {
            return const ErrorWidget2(message: 'Piloto não encontrado');
          }

          final totalPts = history.fold<double>(
            0,
            (acc, r) =>
                acc + (double.tryParse(r.results[0].points) ?? 0),
          );
          final wins =
              history.where((r) => r.results[0].position == '1').length;
          final podiums = history
              .where((r) =>
                  (int.tryParse(r.results[0].position) ?? 99) <= 3)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Driver hero
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [F1Theme.surface, Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: const BorderSide(color: F1Theme.red, width: 4),
                    top: const BorderSide(color: F1Theme.border),
                    right: const BorderSide(color: F1Theme.border),
                    bottom: const BorderSide(color: F1Theme.border),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '#${driver.permanentNumber ?? '—'}',
                      style: const TextStyle(
                        color: F1Theme.red,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.fullName,
                            style: const TextStyle(
                              color: F1Theme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (driverResult != null)
                            Text(driverResult.constructor.name,
                                style: const TextStyle(
                                    color: F1Theme.textSecondary,
                                    fontSize: 13)),
                          if (driver.nationality != null)
                            Text('🌍 ${driver.nationality}',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 12)),
                          if (driver.dateOfBirth != null)
                            Text('🎂 ${driver.dateOfBirth}',
                                style: const TextStyle(
                                    color: F1Theme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _StatCard(
                      value: totalPts.toInt().toString(),
                      label: 'Pontos'),
                  _StatCard(value: wins.toString(), label: 'Vitórias'),
                  _StatCard(value: podiums.toString(), label: 'Pódios'),
                  _StatCard(
                      value: history.length.toString(),
                      label: 'Corridas'),
                ],
              ),
              const SizedBox(height: 20),

              SectionTitle(
                  text:
                      'Temporada ${DateTime.now().year}'),
              ...history.map((r) {
                final res = r.results[0];
                final pos = int.tryParse(res.position) ?? 99;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: pos == 1
                        ? F1Theme.surface
                        : F1Theme.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: pos == 1
                          ? const BorderSide(
                              color: F1Theme.red, width: 3)
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
                        child: Text('R${r.round}',
                            style: const TextStyle(
                                color: F1Theme.textMuted,
                                fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r.name,
                            style: const TextStyle(
                                color: F1Theme.textSecondary,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(res.position,
                          style: const TextStyle(
                              color: F1Theme.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(width: 12),
                      Text('${res.points}pts',
                          style: const TextStyle(
                              color: F1Theme.textMuted,
                              fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      );
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: F1Theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: F1Theme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: const TextStyle(
                    color: F1Theme.red,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: F1Theme.textMuted, fontSize: 11)),
          ],
        ),
      );
}
