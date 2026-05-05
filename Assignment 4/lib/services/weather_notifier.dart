import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../services/weather_api.dart';
import '../services/storage.dart';

class WeatherNotifier extends ChangeNotifier {
  WeatherData? _data;
  bool _isLoading = false;
  String? _error;
  String _units = 'metric';
  SavedCity? _currentCity;

  WeatherData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get units => _units;
  SavedCity? get currentCity => _currentCity;

  Future<void> init() async {
    _units = await getUnits();
    _currentCity = await getLastCity();
    if (_currentCity != null) {
      await _fetchWeather();
    }
    notifyListeners();
  }

  Future<void> loadCity(SavedCity city) async {
    _currentCity = city;
    await setLastCity(city);
    await _fetchWeather();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetchWeather();
    notifyListeners();
  }

  Future<void> updateUnits(String newUnits) async {
    _units = newUnits;
    await setUnits(newUnits);
    if (_currentCity != null) {
      await _fetchWeather();
    }
    notifyListeners();
  }

  Future<void> _fetchWeather() async {
    if (_currentCity == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiKey = await getApiKey();
      if (apiKey.isEmpty) {
        _error = 'No API key set. Go to Settings to add your OpenWeatherMap key.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      _units = await getUnits();
      _data = await fetchWeatherByCoords(
        _currentCity!.lat,
        _currentCity!.lon,
        apiKey,
        _units,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
