import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

const _keyApiKey = 'weather_api_key';
const _keyUnits = 'weather_units';
const _keySavedCities = 'weather_saved_cities';
const _keyLastCity = 'weather_last_city';

Future<String> getApiKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyApiKey) ?? '';
}

Future<void> setApiKey(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyApiKey, key);
}

Future<String> getUnits() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyUnits) ?? 'metric';
}

Future<void> setUnits(String units) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyUnits, units);
}

Future<List<SavedCity>> getSavedCities() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keySavedCities);
  if (raw == null) return [];
  final list = jsonDecode(raw) as List;
  return list.map((e) => SavedCity.fromJson(e)).toList();
}

Future<void> saveCity(SavedCity city) async {
  final cities = await getSavedCities();
  final exists = cities.any((c) => c.lat == city.lat && c.lon == city.lon);
  if (!exists) {
    cities.insert(0, city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keySavedCities, jsonEncode(cities.take(10).toList()));
  }
}

Future<void> removeCity(double lat, double lon) async {
  final cities = await getSavedCities();
  final filtered = cities.where((c) => !(c.lat == lat && c.lon == lon)).toList();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keySavedCities, jsonEncode(filtered));
}

Future<SavedCity?> getLastCity() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keyLastCity);
  if (raw == null) return null;
  return SavedCity.fromJson(jsonDecode(raw));
}

Future<void> setLastCity(SavedCity city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLastCity, jsonEncode(city.toJson()));
}
