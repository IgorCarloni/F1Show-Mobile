import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/f1_api.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Race> _future;

  @override
  void initState() {
    super.initState();
    _future = F1ApiService.getLastRace();
    AnalyticsService.logScreenView('home');
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
          final winner = race.results.isNotEmpty ? race.results[0] : null;
          return RefreshIndicator(
            color: F1Theme.red,
            onRefresh: () async {
              setState(() => _future = F1ApiService.getLastRace());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [F1Theme.red, Color(0xFFA00400)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '🏎️ Bem vindo a F1 Show onde a velocidade não para!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Hero card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [F1Theme.surface, Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: F1Theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RedBadge(text: 'ÚLTIMA CORRIDA'),
                      const SizedBox(height: 12),
                      Text(
                        race.name,
                        style: const TextStyle(
                          color: F1Theme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🏁 Rodada ${race.round}  •  📅 ${race.date}',
                        style: const TextStyle(
                            color: F1Theme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${race.circuit.name}',
                        style: const TextStyle(
                            color: F1Theme.textMuted, fontSize: 12),
                      ),
                      Text(
                        '${race.circuit.locality}, ${race.circuit.country}',
                        style: const TextStyle(
                            color: F1Theme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Winner card
                if (winner != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [F1Theme.surface, Color(0xFF2A1A1A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: F1Theme.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🏆 VENCEDOR',
                            style: TextStyle(
                                color: F1Theme.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          winner.driver.fullName,
                          style: const TextStyle(
                            color: F1Theme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            InfoTag(text: winner.constructor.name),
                            InfoTag(
                                text:
                                    'Volta rápida: ${winner.fastestLap ?? 'N/A'}'),
                            InfoTag(
                                text:
                                    'Tempo: ${winner.time ?? 'N/A'}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: F1Theme.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => context.go('/results'),
                            child: const Text('Ver todos os resultados →'),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Podium
                const SectionTitle(text: 'Pódio'),
                Row(
                  children: race.results.take(3).toList().asMap().entries.map(
                    (e) {
                      final i = e.key;
                      final r = e.value;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            AnalyticsService.logDriverView(
                                r.driver.id, r.driver.fullName);
                            context.go('/driver/${r.driver.id}');
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: i == 0 ? 0 : 6,
                              right: i == 2 ? 0 : 6,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: F1Theme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: F1Theme.border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  i == 0 ? '🥇' : i == 1 ? '🥈' : '🥉',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r.driver.familyName,
                                  style: const TextStyle(
                                    color: F1Theme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  r.constructor.name,
                                  style: const TextStyle(
                                      color: F1Theme.textMuted, fontSize: 10),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${r.points} pts',
                                  style: const TextStyle(
                                    color: F1Theme.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          );
        },
      );
}
