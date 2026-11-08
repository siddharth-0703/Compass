import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/storage/hive_storage.dart';

class WeatherData {
  final String temperature;
  final String condition;
  final String locationName;
  final int humidity;
  final double windSpeed;
  final bool isFromCache;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.locationName,
    required this.humidity,
    required this.windSpeed,
    this.isFromCache = false,
  });
}

class WeatherService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  /// Returns cached weather immediately, then updates in background.
  WeatherData getCachedWeather() {
    final box = HiveStorage.settingsBox;
    final temp = box.get('weather_temp', defaultValue: '28°C') as String;
    final cond = box.get('weather_cond', defaultValue: 'Clear Sky') as String;
    final loc = box.get('weather_loc', defaultValue: 'Maharashtra') as String;
    final hum = box.get('weather_hum', defaultValue: 62) as int;
    final wind = box.get('weather_wind', defaultValue: 12.0) as double;

    return WeatherData(
      temperature: temp,
      condition: cond,
      locationName: loc,
      humidity: hum,
      windSpeed: wind,
      isFromCache: true,
    );
  }

  /// Fetches real-time weather using device GPS location with instant offline fallback.
  Future<WeatherData> fetchLiveWeather() async {
    final cached = getCachedWeather();

    double lat = 19.7515; // Maharashtra default
    double lon = 75.7139;
    String locationName = cached.locationName;

    try {
      // 1. Check and request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );
          lat = position.latitude;
          lon = position.longitude;
          locationName = 'Current Location';
        }
      }
    } catch (_) {
      // Retain fallback lat/lon
    }

    try {
      // 2. Fetch live weather from Open-Meteo
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final current = response.data['current'];
        final tempVal = (current['temperature_2m'] as num).round();
        final tempStr = '$tempVal°C';
        final humVal = (current['relative_humidity_2m'] as num).toInt();
        final windVal = (current['wind_speed_10m'] as num).toDouble();
        final code = (current['weather_code'] as num).toInt();
        final condStr = _getConditionFromWmo(code);

        // Cache for production grade persistence
        final box = HiveStorage.settingsBox;
        await box.put('weather_temp', tempStr);
        await box.put('weather_cond', condStr);
        await box.put('weather_loc', locationName);
        await box.put('weather_hum', humVal);
        await box.put('weather_wind', windVal);

        return WeatherData(
          temperature: tempStr,
          condition: condStr,
          locationName: locationName,
          humidity: humVal,
          windSpeed: windVal,
          isFromCache: false,
        );
      }
    } catch (_) {
      // Silently return previous cached weather
    }

    return cached;
  }

  String _getConditionFromWmo(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Light Drizzle';
    if (code <= 65) return 'Rainy';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear Sky';
  }
}
