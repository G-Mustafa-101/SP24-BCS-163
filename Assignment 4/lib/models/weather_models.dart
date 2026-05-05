class WeatherCurrent {
  final String city;
  final String country;
  final double lat;
  final double lon;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int visibility;
  final int pressure;
  final double uvi;
  final String description;
  final String icon;
  final String condition;
  final int sunrise;
  final int sunset;
  final int dt;

  WeatherCurrent({
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.visibility,
    required this.pressure,
    required this.uvi,
    required this.description,
    required this.icon,
    required this.condition,
    required this.sunrise,
    required this.sunset,
    required this.dt,
  });
}

class HourlyForecast {
  final int dt;
  final double temp;
  final String icon;
  final String description;
  final double pop;

  HourlyForecast({
    required this.dt,
    required this.temp,
    required this.icon,
    required this.description,
    required this.pop,
  });
}

class DailyForecast {
  final int dt;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;
  final double pop;
  final int humidity;
  final double windSpeed;
  final int sunrise;
  final int sunset;

  DailyForecast({
    required this.dt,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
    required this.pop,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });
}

class GeoLocation {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  GeoLocation({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });
}

class WeatherData {
  final WeatherCurrent current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}

class SavedCity {
  final String name;
  final String country;
  final double lat;
  final double lon;

  SavedCity({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
      };

  factory SavedCity.fromJson(Map<String, dynamic> json) => SavedCity(
        name: json['name'],
        country: json['country'],
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
      );
}
