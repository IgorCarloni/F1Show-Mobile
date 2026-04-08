class Driver {
  final String id;
  final String givenName;
  final String familyName;
  final String? code;
  final String? permanentNumber;
  final String? nationality;
  final String? dateOfBirth;

  const Driver({
    required this.id,
    required this.givenName,
    required this.familyName,
    this.code,
    this.permanentNumber,
    this.nationality,
    this.dateOfBirth,
  });

  String get fullName => '$givenName $familyName';

  factory Driver.fromJson(Map<String, dynamic> j) => Driver(
        id: j['driverId'],
        givenName: j['givenName'],
        familyName: j['familyName'],
        code: j['code'],
        permanentNumber: j['permanentNumber'],
        nationality: j['nationality'],
        dateOfBirth: j['dateOfBirth'],
      );
}

class Constructor {
  final String id;
  final String name;
  final String? nationality;

  const Constructor({required this.id, required this.name, this.nationality});

  factory Constructor.fromJson(Map<String, dynamic> j) => Constructor(
        id: j['constructorId'],
        name: j['name'],
        nationality: j['nationality'],
      );
}

class RaceResult {
  final String position;
  final String number;
  final String points;
  final String laps;
  final String status;
  final String? time;
  final String? fastestLap;
  final Driver driver;
  final Constructor constructor;

  const RaceResult({
    required this.position,
    required this.number,
    required this.points,
    required this.laps,
    required this.status,
    this.time,
    this.fastestLap,
    required this.driver,
    required this.constructor,
  });

  factory RaceResult.fromJson(Map<String, dynamic> j) => RaceResult(
        position: j['position'],
        number: j['number'],
        points: j['points'],
        laps: j['laps'],
        status: j['status'],
        time: j['Time']?['time'],
        fastestLap: j['FastestLap']?['Time']?['time'],
        driver: Driver.fromJson(j['Driver']),
        constructor: Constructor.fromJson(j['Constructor']),
      );
}

class Circuit {
  final String name;
  final String locality;
  final String country;

  const Circuit(
      {required this.name, required this.locality, required this.country});

  factory Circuit.fromJson(Map<String, dynamic> j) => Circuit(
        name: j['circuitName'],
        locality: j['Location']['locality'],
        country: j['Location']['country'],
      );
}

class Race {
  final String season;
  final String round;
  final String name;
  final String date;
  final Circuit circuit;
  final List<RaceResult> results;

  const Race({
    required this.season,
    required this.round,
    required this.name,
    required this.date,
    required this.circuit,
    required this.results,
  });

  factory Race.fromJson(Map<String, dynamic> j) => Race(
        season: j['season'],
        round: j['round'],
        name: j['raceName'],
        date: j['date'],
        circuit: Circuit.fromJson(j['Circuit']),
        results: (j['Results'] as List? ?? [])
            .map((r) => RaceResult.fromJson(r))
            .toList(),
      );
}

class DriverStanding {
  final String position;
  final String points;
  final String wins;
  final Driver driver;
  final List<Constructor> constructors;

  const DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driver,
    required this.constructors,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> j) => DriverStanding(
        position: j['position'],
        points: j['points'],
        wins: j['wins'],
        driver: Driver.fromJson(j['Driver']),
        constructors: (j['Constructors'] as List)
            .map((c) => Constructor.fromJson(c))
            .toList(),
      );
}

class ConstructorStanding {
  final String position;
  final String points;
  final String wins;
  final Constructor constructor;

  const ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructor,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> j) =>
      ConstructorStanding(
        position: j['position'],
        points: j['points'],
        wins: j['wins'],
        constructor: Constructor.fromJson(j['Constructor']),
      );
}

class StandingsList<T> {
  final String season;
  final String round;
  final List<T> standings;

  const StandingsList(
      {required this.season, required this.round, required this.standings});
}
