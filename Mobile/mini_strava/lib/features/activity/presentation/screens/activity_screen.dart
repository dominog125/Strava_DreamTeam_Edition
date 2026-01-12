import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controller/activity_controller.dart';
import '../../domain/entities/activity.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController c;

  final MapController _mapController = MapController();
  bool _mapReady = false;
  LatLng? _pendingMoveTo;

  LatLng? _current;
  String? _locError;
  bool _locLoading = true;

  @override
  void initState() {
    super.initState();
    c = ActivityController()..addListener(_onChanged);
    _initLocation();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onChanged);
    c.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _locLoading = true;
      _locError = null;
    });

    try {
      final enabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _locError = 'Włącz usługi lokalizacji (GPS).';
          _locLoading = false;
        });
        return;
      }

      var perm = await geo.Geolocator.checkPermission();
      if (perm == geo.LocationPermission.denied) {
        perm = await geo.Geolocator.requestPermission();
      }
      if (perm == geo.LocationPermission.denied) {
        setState(() {
          _locError = 'Brak zgody na lokalizację.';
          _locLoading = false;
        });
        return;
      }
      if (perm == geo.LocationPermission.deniedForever) {
        setState(() {
          _locError = 'Zgoda na lokalizację zablokowana w ustawieniach.';
          _locLoading = false;
        });
        return;
      }

      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
      );

      final ll = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _current = ll;
        _locLoading = false;
        _locError = null;
      });

      // NIE ruszaj mapy zanim się nie wyrenderuje:
      if (_mapReady) {
        _mapController.move(ll, 16);
      } else {
        _pendingMoveTo = ll;
      }
    } catch (e) {
      setState(() {
        _locError = 'Nie udało się pobrać lokalizacji: $e';
        _locLoading = false;
      });
    }
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = c.state == ActivityState.idle;
    final isRunning = c.state == ActivityState.running;
    final isPaused = c.state == ActivityState.paused;

    final center = _current ?? const LatLng(52.2297, 21.0122);

    return Scaffold(
      appBar: AppBar(title: const Text('Nowa aktywność')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _locLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _locError != null
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_locError!, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _initLocation,
                          child: const Text('Spróbuj ponownie'),
                        ),
                      ],
                    ),
                  ),
                )
                    : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: _current == null ? 10 : 16,
                    onMapReady: () {
                      _mapReady = true;
                      if (_pendingMoveTo != null) {
                        _mapController.move(_pendingMoveTo!, 16);
                        _pendingMoveTo = null;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mini_strava',
                    ),
                    if (_current != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _current!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location, size: 32),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<ActivityType>(
              initialValue: c.type,
              decoration: const InputDecoration(labelText: 'Typ aktywności'),
              items: const [
                DropdownMenuItem(value: ActivityType.run, child: Text('Bieg')),
                DropdownMenuItem(value: ActivityType.bike, child: Text('Rower')),
                DropdownMenuItem(value: ActivityType.walk, child: Text('Spacer')),
              ],
              onChanged: isIdle ? (v) => c.setType(v ?? ActivityType.run) : null,
            ),

            const SizedBox(height: 24),
            Text(_format(c.elapsed), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isIdle ? c.start : null,
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRunning ? c.pause : (isPaused ? c.resume : null),
                    child: Text(isPaused ? 'Wznów' : 'Pauza'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (isRunning || isPaused) ? () => c.finish(context) : null,
                child: const Text('Zakończ i zapisz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
