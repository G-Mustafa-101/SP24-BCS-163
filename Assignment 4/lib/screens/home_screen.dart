import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_notifier.dart';
import '../widgets/weather_background.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  final WeatherNotifier notifier;

  const HomeScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final data = notifier.data;
        final current = data?.current;
        final isDay = current != null
            ? current.dt > current.sunrise && current.dt < current.sunset
            : true;
        final condition = current?.condition ?? 'clear';

        if (notifier.currentCity == null && !notifier.isLoading) {
          return Stack(
            children: [
              const WeatherBackground(condition: 'clear', isDay: true),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌍', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text('No Location Set',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 8),
                      Text('Go to Search tab to find a city',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 15,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            WeatherBackground(condition: condition, isDay: isDay),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: notifier.refresh,
                color: Colors.white.withValues(alpha: 0.8),
                backgroundColor: Colors.transparent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.white.withValues(alpha: 0.85), size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  current != null
                                      ? '${current.city}, ${current.country}'
                                      : notifier.currentCity?.name ?? '',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: notifier.refresh,
                              icon: Icon(Icons.refresh,
                                  color: Colors.white.withValues(alpha: 0.8), size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (notifier.isLoading && data == null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Colors.white.withValues(alpha: 0.8)),
                                const SizedBox(height: 16),
                                Text('Fetching weather...',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                              ],
                            ),
                          ),
                        ),

                      if (notifier.error != null)
                        WeatherCard(
                          child: Text(notifier.error!,
                              style: const TextStyle(color: Color(0xFFFFCCCB), fontSize: 14),
                              textAlign: TextAlign.center),
                        ),

                      if (current != null) ...[
                        // Main temp
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(getWeatherEmoji(current.icon),
                                  style: const TextStyle(fontSize: 80)),
                              Text(
                                formatTemp(current.temp, notifier.units),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 88,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -2,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                capitalize(current.description),
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Feels like ${formatTemp(current.feelsLike, notifier.units)}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // Stats
                        WeatherCard(
                          title: 'Conditions',
                          child: Row(
                            children: [
                              StatTile(label: 'Humidity', value: '${current.humidity}%', icon: '💧'),
                              StatTile(label: 'Wind', value: formatWindSpeed(current.windSpeed, notifier.units), icon: '💨'),
                              StatTile(label: 'Pressure', value: '${current.pressure} hPa', icon: '🌡️'),
                              StatTile(label: 'UV Index', value: '${current.uvi}', icon: '☀️'),
                            ],
                          ),
                        ),

                        // Sunrise / Sunset
                        WeatherCard(
                          title: 'Sun',
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('🌅', style: TextStyle(fontSize: 28)),
                                    const SizedBox(height: 6),
                                    Text(formatTime(current.sunrise),
                                        style: GoogleFonts.outfit(
                                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text('Sunrise',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.2)),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('🌇', style: TextStyle(fontSize: 28)),
                                    const SizedBox(height: 6),
                                    Text(formatTime(current.sunset),
                                        style: GoogleFonts.outfit(
                                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text('Sunset',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Hourly
                        if (data!.hourly.isNotEmpty)
                          WeatherCard(
                            title: 'Hourly',
                            child: SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: data.hourly.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final h = data.hourly[i];
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        i == 0 ? 'Now' : formatHour(h.dt),
                                        style: GoogleFonts.outfit(
                                            color: Colors.white.withValues(alpha: 0.65),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(getWeatherEmoji(h.icon), style: const TextStyle(fontSize: 24)),
                                      if (h.pop > 0.1)
                                        Text('💧 ${((h.pop * 100).round())}%',
                                            style: const TextStyle(color: Color(0xFF87CEEB), fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(formatTemp(h.temp, notifier.units),
                                          style: GoogleFonts.outfit(
                                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                        // Visibility
                        WeatherCard(
                          child: Row(
                            children: [
                              const Text('👁️', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(current.visibility / 1000).toStringAsFixed(1)} km',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  Text('Visibility',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
