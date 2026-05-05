import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';

String _mapCondition(int id) {
  if (id >= 200 && id < 300) return 'thunderstorm';
  if (id >= 300 && id < 400) return 'drizzle';
  if (id >= 500 && id < 600) return 'rain';
  if (id >= 600 && id < 700) return 'snow';
  if (id >= 700 && id < 800) return 'mist';
  if (id == 800) return 'clear';
  if (id == 801 || id == 802) return 'few-clouds';
  if (id >= 803) return 'clouds';
  return 'clear';
}

Future<WeatherData> fetchWeatherByCoords(
  double lat,
  double lon,
  String apiKey,
  String units,
) async {
  final results = await Future.wait([
    http.get(Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=$units')),
    http.get(Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=$units&cnt=48')),
    http.get(Uri.parse(
        '$_baseUrl/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=$units&exclude=minutely,alerts')),
  ]);

  if (results[0].statusCode != 200) {
    final err = jsonDecode(results[0].body);
    throw Exception(err['message'] ?? 'Weather API error');
  }

  final currentJson = jsonDecode(results[0].body);
  Map<String, dynamic>? oneCallJson;
  Map<String, dynamic>? forecastJson;

  if (results[2].statusCode == 200) {
    oneCallJson = jsonDecode(results[2].body);
  }
  if (results[1].statusCode == 200) {
    forecastJson = jsonDecode(results[1].body);
  }

  final current = WeatherCurrent(
    city: currentJson['name'],
    country: currentJson['sys']['country'],
    lat: (currentJson['coord']['lat'] as num).toDouble(),
    lon: (currentJson['coord']['lon'] as num).toDouble(),
    temp: (currentJson['main']['temp'] as num).toDouble(),
    feelsLike: (currentJson['main']['feels_like'] as num).toDouble(),
    humidity: currentJson['main']['humidity'],
    windSpeed: (currentJson['wind']['speed'] as num).toDouble(),
    windDeg: currentJson['wind']['deg'] ?? 0,
    visibility: currentJson['visibility'] ?? 0,
    pressure: currentJson['main']['pressure'],
    uvi: oneCallJson?['current']?['uvi'] != null
        ? (oneCallJson!['current']['uvi'] as num).toDouble()
        : 0,
    description: currentJson['weather'][0]['description'],
    icon: currentJson['weather'][0]['icon'],
    condition: _mapCondition(currentJson['weather'][0]['id']),
    sunrise: currentJson['sys']['sunrise'],
    sunset: currentJson['sys']['sunset'],
    dt: currentJson['dt'],
  );

  List<HourlyForecast> hourly = [];
  if (oneCallJson?['hourly'] != null) {
    for (var h in (oneCallJson!['hourly'] as List).take(24)) {
      hourly.add(HourlyForecast(
        dt: h['dt'],
        temp: (h['temp'] as num).toDouble(),
        icon: h['weather'][0]['icon'],
        description: h['weather'][0]['description'],
        pop: (h['pop'] ?? 0).toDouble(),
      ));
    }
  } else if (forecastJson?['list'] != null) {
    for (var h in (forecastJson!['list'] as List).take(16)) {
      hourly.add(HourlyForecast(
        dt: h['dt'],
        temp: (h['main']['temp'] as num).toDouble(),
        icon: h['weather'][0]['icon'],
        description: h['weather'][0]['description'],
        pop: (h['pop'] ?? 0).toDouble(),
      ));
    }
  }

  List<DailyForecast> daily = [];
  if (oneCallJson?['daily'] != null) {
    for (var d in (oneCallJson!['daily'] as List).take(30)) {
      daily.add(DailyForecast(
        dt: d['dt'],
        tempMin: (d['temp']['min'] as num).toDouble(),
        tempMax: (d['temp']['max'] as num).toDouble(),
        icon: d['weather'][0]['icon'],
        description: d['weather'][0]['description'],
        pop: (d['pop'] ?? 0).toDouble(),
        humidity: d['humidity'],
        windSpeed: (d['wind_speed'] as num).toDouble(),
        sunrise: d['sunrise'],
        sunset: d['sunset'],
      ));
    }
  } else if (forecastJson?['list'] != null) {
    final dayMap = <String, List<dynamic>>{};
    for (var item in forecastJson!['list'] as List) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
          .toIso8601String()
          .substring(0, 10);
      dayMap.putIfAbsent(date, () => []).add(item);
    }
    int i = 0;
    for (var entries in dayMap.values) {
      if (i >= 10) break;
      final temps = entries.map<double>((e) => (e['main']['temp'] as num).toDouble()).toList();
      final mid = entries[entries.length ~/ 2];
      daily.add(DailyForecast(
        dt: mid['dt'],
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        icon: mid['weather'][0]['icon'],
        description: mid['weather'][0]['description'],
        pop: (mid['pop'] ?? 0).toDouble(),
        humidity: mid['main']['humidity'],
        windSpeed: (mid['wind']['speed'] as num).toDouble(),
        sunrise: currentJson['sys']['sunrise'],
        sunset: currentJson['sys']['sunset'],
      ));
      i++;
    }
  }

  return WeatherData(current: current, hourly: hourly, daily: daily);
}

Future<List<GeoLocation>> searchLocations(String query, String apiKey) async {
  final res = await http.get(Uri.parse(
      '$_geoUrl/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$apiKey'));
  if (res.statusCode != 200) throw Exception('Geocoding failed');
  final data = jsonDecode(res.body) as List;
  return data.map((item) => GeoLocation(
        name: item['name'],
        country: item['country'],
        state: item['state'],
        lat: (item['lat'] as num).toDouble(),
        lon: (item['lon'] as num).toDouble(),
      )).toList();
}
