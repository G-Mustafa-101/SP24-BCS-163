import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_models.dart';
import '../services/weather_api.dart';
import '../services/storage.dart';
import '../services/weather_notifier.dart';
import '../widgets/weather_background.dart';
import '../widgets/shared_widgets.dart';

class SearchScreen extends StatefulWidget {
  final WeatherNotifier notifier;
  const SearchScreen({super.key, required this.notifier});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<GeoLocation> _results = [];
  bool _searching = false;
  String _searchError = '';
  List<SavedCity> _savedCities = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final cities = await getSavedCities();
    if (mounted) setState(() => _savedCities = cities);
  }

  Future<void> _doSearch() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = '';
      _results = [];
    });

    try {
      final apiKey = await getApiKey();
      if (apiKey.isEmpty) {
        setState(() {
          _searchError = 'No API key set. Go to Settings first.';
          _searching = false;
        });
        return;
      }
      final locs = await searchLocations(_controller.text.trim(), apiKey);
      setState(() {
        _results = locs;
        _searching = false;
        if (locs.isEmpty) _searchError = 'No locations found. Try a different name.';
      });
    } catch (e) {
      setState(() {
        _searchError = e.toString().replaceFirst('Exception: ', '');
        _searching = false;
      });
    }
  }

  Future<void> _selectLocation(GeoLocation loc) async {
    final city = SavedCity(name: loc.name, country: loc.country, lat: loc.lat, lon: loc.lon);
    await widget.notifier.loadCity(city);
    _controller.clear();
    setState(() {
      _results = [];
    });
    _loadSaved();
  }

  Future<void> _toggleSave(SavedCity city) async {
    final isSaved = _savedCities.any((c) => c.lat == city.lat && c.lon == city.lon);
    if (isSaved) {
      await removeCity(city.lat, city.lon);
    } else {
      await saveCity(city);
    }
    _loadSaved();
  }

  Future<void> _loadSavedCity(SavedCity city) async {
    await widget.notifier.loadCity(city);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            padding: EdgeInsets.only(top: 8, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Search',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                ),

                // Search bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white.withOpacity(0.6), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _doSearch(),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _results = [];
                              _searchError = '';
                            });
                          },
                          child: Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 18),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Search button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _searching ? null : _doSearch,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.22),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.white.withOpacity(0.25)),
                      ),
                    ),
                    child: _searching
                        ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Search',
                            style: GoogleFonts.outfit(
                                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                  ),
                ),

                if (_searchError.isNotEmpty)
                  WeatherCard(
                    child: Text(_searchError,
                        style: TextStyle(color: Color(0xFFFFCCCB), fontSize: 14),
                        textAlign: TextAlign.center),
                  ),

                // Results
                if (_results.isNotEmpty)
                  WeatherCard(
                    title: 'Results',
                    child: Column(
                      children: _results.asMap().entries.map((entry) {
                        final i = entry.key;
                        final loc = entry.value;
                        final city = SavedCity(name: loc.name, country: loc.country, lat: loc.lat, lon: loc.lon);
                        final isSaved = _savedCities.any((c) => c.lat == loc.lat && c.lon == loc.lon);
                        final isCurrent = widget.notifier.currentCity?.lat == loc.lat &&
                            widget.notifier.currentCity?.lon == loc.lon;

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectLocation(loc),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: isCurrent ? Color(0xFF7BC8F0) : Colors.white.withOpacity(0.6),
                                              size: 16),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(loc.name,
                                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                                SizedBox(height: 2),
                                                Text(
                                                  '${loc.state != null ? '${loc.state}, ' : ''}${loc.country}',
                                                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.55), fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isCurrent)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF87CEEB).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Color(0xFF87CEEB).withOpacity(0.4)),
                                              ),
                                              child: Text('Active',
                                                  style: GoogleFonts.outfit(color: Color(0xFF87CEEB), fontSize: 11, fontWeight: FontWeight.w600)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _toggleSave(city),
                                    icon: Icon(
                                      isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                      color: isSaved ? Color(0xFF7BC8F0) : Colors.white.withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < _results.length - 1)
                              Divider(color: Colors.white.withOpacity(0.08), height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                // Saved cities
                if (_savedCities.isNotEmpty)
                  WeatherCard(
                    title: 'Saved Cities',
                    child: Column(
                      children: _savedCities.asMap().entries.map((entry) {
                        final i = entry.key;
                        final city = entry.value;
                        final isCurrent = widget.notifier.currentCity?.lat == city.lat &&
                            widget.notifier.currentCity?.lon == city.lon;

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _loadSavedCity(city),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: isCurrent ? Color(0xFF7BC8F0) : Colors.white.withOpacity(0.6),
                                              size: 16),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(city.name,
                                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                                SizedBox(height: 2),
                                                Text(city.country,
                                                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.55), fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          if (isCurrent)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF87CEEB).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Color(0xFF87CEEB).withOpacity(0.4)),
                                              ),
                                              child: Text('Active',
                                                  style: GoogleFonts.outfit(color: Color(0xFF87CEEB), fontSize: 11, fontWeight: FontWeight.w600)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _toggleSave(city),
                                    icon: Icon(Icons.bookmark, color: Color(0xFF7BC8F0), size: 20),
                                  ),
                                ],
                              ),
                            ),
                            if (i < _savedCities.length - 1)
                              Divider(color: Colors.white.withOpacity(0.08), height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
