import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class F1ApiService {
  static const _base = 'https://api.jolpi.ca/ergast/f1';

  static Future<T> _get<T>(
      String path, T Function(Map<String, dynamic>) parser) async {
    final res = await http.get(Uri.parse('$_base$path'));
    if (res.statusCode != 200) throw Exception('Erro ao buscar dados');
    return parser(jsonDecode(res.body)['MRData']);
  }

  static Future<Race> getLastRace() => _get(
        '/current/last/results.json',
        (d) => Race.fromJson(d['RaceTable']['Races'][0]),
      );

  static Future<List<Race>> getSeasonRaces(String year) => _get(
        '/$year/races.json?limit=30',
        (d) => (d['RaceTable']['Races'] as List)
            .map((r) => Race.fromJson(r))
            .toList(),
      );

  static Future<Race> getRaceResult(String year, String round) => _get(
        '/$year/$round/results.json',
        (d) => Race.fromJson(d['RaceTable']['Races'][0]),
      );

  static Future<StandingsList<DriverStanding>> getDriverStandings(
          String year) =>
      _get(
        '/$year/driverStandings.json',
        (d) {
          final list = d['StandingsTable']['StandingsLists'];
          if (list == null || (list as List).isEmpty) {
            return StandingsList<DriverStanding>(
                season: year, round: '0', standings: []);
          }
          final sl = list[0];
          return StandingsList<DriverStanding>(
            season: sl['season'],
            round: sl['round'],
            standings: (sl['DriverStandings'] as List)
                .map((s) => DriverStanding.fromJson(s))
                .toList(),
          );
        },
      );

  static Future<StandingsList<ConstructorStanding>> getConstructorStandings(
          String year) =>
      _get(
        '/$year/constructorStandings.json',
        (d) {
          final list = d['StandingsTable']['StandingsLists'];
          if (list == null || (list as List).isEmpty) {
            return StandingsList<ConstructorStanding>(
                season: year, round: '0', standings: []);
          }
          final sl = list[0];
          return StandingsList<ConstructorStanding>(
            season: sl['season'],
            round: sl['round'],
            standings: (sl['ConstructorStandings'] as List)
                .map((s) => ConstructorStanding.fromJson(s))
                .toList(),
          );
        },
      );

  static Future<List<Race>> getDriverHistory(String driverId) => _get(
        '/current/drivers/$driverId/results.json',
        (d) => (d['RaceTable']['Races'] as List)
            .map((r) => Race.fromJson(r))
            .toList(),
      );
}
