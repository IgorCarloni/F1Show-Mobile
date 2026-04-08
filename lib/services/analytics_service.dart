import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  static Future<void> logDriverView(String driverId, String driverName) =>
      _analytics.logEvent(
        name: 'driver_view',
        parameters: {'driver_id': driverId, 'driver_name': driverName},
      );

  static Future<void> logSeasonSelect(String year) =>
      _analytics.logEvent(name: 'season_select', parameters: {'year': year});

  static Future<void> logRaceSelect(String raceName) =>
      _analytics.logEvent(
          name: 'race_select', parameters: {'race_name': raceName});
}
