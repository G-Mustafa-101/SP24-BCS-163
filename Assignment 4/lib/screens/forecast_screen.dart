import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_notifier.dart';
import '../widgets/weather_background.dart';
import '../widgets/shared_widgets.dart';

class ForecastScreen extends StatefulWidget {
  final WeatherNotifier notifier;
  const ForecastScreen({super.key, required this.notifier});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _rangeDays = 7;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final data = widget.notifier.data;
        final current = data?.current;
        final isDay = current != null
            ? current.dt > current.sunrise && current.dt < current.sunset
            : true;
        final condition = current?.condition ?? 'clear';
        final daily = data?.daily.take(_rangeDays).toList() ?? [];

        return Stack(
          children: [
            WeatherBackground(condition: condition, isDay: isDay),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 8, bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Forecast',
                              style: GoogleFonts.outfit(
                                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                          if (current != null)
                            Text('${current.city}, ${current.country}',
                                style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.6), fontSize: 14)),
                        ],
                      ),
                    ),

                    // Range selector
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [7, 14, 30].map((days) {
                          final isActive = _rangeDays == days;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _rangeDays = days),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white.withOpacity(0.25) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$days days',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    if (widget.notifier.isLoading && data == null)
                      Center(child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: Colors.white.withOpacity(0.9)),
                      )),

                    if (widget.notifier.error != null)
                      WeatherCard(
                        child: Text(widget.notifier.error!,
                            style: TextStyle(color: Color(0xFFFFCCCB), fontSize: 14),
                            textAlign: TextAlign.center),
                      ),

                    if (data == null && !widget.notifier.isLoading && widget.notifier.error == null)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              Text('📅', style: TextStyle(fontSize: 56)),
                              SizedBox(height: 12),
                              Text('No forecast available',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              Text('Search a city to see forecast',
                                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 15)),
                            ],
                          ),
                        ),
                      ),

                    if (daily.isNotEmpty)
                      WeatherCard(
                        title: '$_rangeDays-Day Forecast',
                        child: Column(
                          children: daily.asMap().entries.map((entry) {
                            final i = entry.key;
                            final day = entry.value;
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              i == 0 ? 'Today' : formatDay(day.dt),
                                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(height: 2),
                                            Text(formatFullDate(day.dt),
                                                style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        child: Column(
                                          children: [
                                            Text(getWeatherEmoji(day.icon), style: TextStyle(fontSize: 26)),
                                            if (day.pop > 0.1)
                                              Text('💧 ${(day.pop * 100).round()}%',
                                                  style: TextStyle(color: Color(0xFF87CEEB), fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(formatTemp(day.tempMax, widget.notifier.units),
                                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                          SizedBox(height: 3),
                                          Text(formatTemp(day.tempMin, widget.notifier.units),
                                              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < daily.length - 1)
                                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                    // Detailed view for 7-day
                    if (daily.isNotEmpty && _rangeDays == 7) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text('DETAILED VIEW',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            )),
                      ),
                      ...daily.take(7).map((day) {
                        return WeatherCard(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        daily.indexOf(day) == 0 ? 'Today' : formatDay(day.dt),
                                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 2),
                                      Text(formatFullDate(day.dt),
                                          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.55), fontSize: 12)),
                                    ],
                                  ),
                                  Text(getWeatherEmoji(day.icon), style: TextStyle(fontSize: 36)),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(capitalize(day.description),
                                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _detailStat(formatTemp(day.tempMax, widget.notifier.units), 'High'),
                                  _detailStat(formatTemp(day.tempMin, widget.notifier.units), 'Low'),
                                  _detailStat('${day.humidity}%', 'Humidity'),
                                  _detailStat(formatWindSpeed(day.windSpeed, widget.notifier.units), 'Wind'),
                                  _detailStat('${(day.pop * 100).round()}%', 'Rain'),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 3),
        Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }
}
