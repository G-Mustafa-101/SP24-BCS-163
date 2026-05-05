import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage.dart';
import '../services/weather_notifier.dart';
import '../widgets/weather_background.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final WeatherNotifier notifier;
  const SettingsScreen({super.key, required this.notifier});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _apiKey = '';
  String _units = 'metric';
  bool _showKey = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final k = await getApiKey();
    final u = await getUnits();
    if (mounted) {
      setState(() {
        _apiKey = k;
        _units = u;
      });
    }
  }

  Future<void> _handleSave() async {
    await setApiKey(_apiKey.trim());
    await widget.notifier.updateUnits(_units);
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.notifier.data;
    final current = data?.current;
    final isDay = current != null
        ? current.dt > current.sunrise && current.dt < current.sunset
        : true;
    final condition = current?.condition ?? 'clear';

    return Stack(
      children: [
        WeatherBackground(condition: condition, isDay: isDay),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Settings',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5)),
                ),

                // API Key
                WeatherCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key,
                              color: Colors.white.withOpacity(0.8), size: 18),
                          const SizedBox(width: 8),
                          Text('API Key',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your OpenWeatherMap API key. Get a free key at openweathermap.org',
                        style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: GoogleFonts.outfit(
                                    color: Colors.white, fontSize: 15),
                                obscureText: !_showKey,
                                decoration: InputDecoration(
                                  hintText: 'Paste your API key here',
                                  hintStyle: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.3)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onChanged: (v) => setState(() => _apiKey = v),
                                controller: TextEditingController(text: _apiKey)
                                  ..selection = TextSelection.fromPosition(
                                      TextPosition(offset: _apiKey.length)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showKey = !_showKey),
                              child: Icon(
                                _showKey
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white.withOpacity(0.5),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_apiKey.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Color(0xFF5CDB95), size: 14),
                            const SizedBox(width: 6),
                            Text('Key entered (${_apiKey.length} chars)',
                                style: GoogleFonts.outfit(
                                    color: const Color(0xFF5CDB95),
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Units
                WeatherCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thermostat,
                              color: Colors.white.withOpacity(0.8), size: 18),
                          const SizedBox(width: 8),
                          Text('Units',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _units == 'metric'
                                      ? 'Celsius (°C)'
                                      : 'Fahrenheit (°F)',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _units == 'metric'
                                      ? 'Metric system'
                                      : 'Imperial system',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text('°C',
                                  style: GoogleFonts.outfit(
                                    color: _units == 'metric'
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(width: 8),
                              Switch(
                                value: _units == 'imperial',
                                onChanged: (val) {
                                  setState(() =>
                                      _units = val ? 'imperial' : 'metric');
                                },
                                activeTrackColor:
                                    const Color(0xFF87CEEB).withOpacity(0.7),
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.3),
                                thumbColor:
                                    const WidgetStatePropertyAll(Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text('°F',
                                  style: GoogleFonts.outfit(
                                    color: _units == 'imperial'
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Save button
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _handleSave,
                    style: TextButton.styleFrom(
                      backgroundColor: _saved
                          ? const Color(0xFF5CDB95).withOpacity(0.3)
                          : const Color(0xFF87CEEB).withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _saved
                              ? const Color(0xFF5CDB95).withOpacity(0.4)
                              : const Color(0xFF87CEEB).withOpacity(0.4),
                        ),
                      ),
                    ),
                    child: _saved
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Saved!',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          )
                        : Text('Save Settings',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3)),
                  ),
                ),

                // About
                WeatherCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.white.withOpacity(0.8), size: 18),
                          const SizedBox(width: 8),
                          Text('About',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This app uses OpenWeatherMap APIs for real-time weather, hourly forecasts, and up to 30-day daily forecasts.',
                        style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Free API keys provide current weather and 5-day/3-hour forecasts. The One Call API (paid) unlocks hourly and 30-day forecasts.',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.white.withOpacity(0.08)),
                      _infoRow('App version', '1.0.0'),
                      _infoRow('Data source', 'OpenWeatherMap'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.55), fontSize: 13)),
          Text(value,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
