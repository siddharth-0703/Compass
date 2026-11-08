import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherData>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return WeatherNotifier(service);
});

class WeatherNotifier extends StateNotifier<WeatherData> {
  final WeatherService _service;

  WeatherNotifier(this._service) : super(_service.getCachedWeather()) {
    refreshWeather();
  }

  Future<void> refreshWeather() async {
    try {
      final updated = await _service.fetchLiveWeather();
      if (mounted) {
        state = updated;
      }
    } catch (_) {
      // Retain previous state
    }
  }
}

