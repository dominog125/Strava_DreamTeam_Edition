import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controller/activity_controller.dart';
import '../../domain/entities/activity.dart' as act;

import '../../../activity_history/domain/entities/gps_point.dart';

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


  StreamSubscription<geo.Position>? _posSub;
  LatLng? _lastForDistance;
  double _distanceKm = 0.0;


  final List<LatLng> _trackPoints = [];


  bool _followUser = false;
  DateTime _lastAutoMove = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    c = ActivityController()..addListener(_onChanged);
    _initLocation();
  }

  void _onChanged() {
    _syncTrackingWithState();
    setState(() {});
  }

  @override
  void dispose() {
    _posSub?.cancel();
    c.removeListener(_onChanged);
    c.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() {
      _locLoading = true;
      _locError = null;
    });

    try {
      final enabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!mounted) return;

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
      if (!mounted) return;

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
      if (!mounted) return;

      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _current = ll;
        _locLoading = false;
        _locError = null;
      });

      _safeMoveMap(ll, 16);
      _syncTrackingWithState();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locError = 'Nie udało się pobrać lokalizacji: $e';
        _locLoading = false;
      });
    }
  }

  void _syncTrackingWithState() {
    final isRunning = c.state == ActivityState.running;
    _followUser = isRunning;

    if (isRunning) {
      _startTracking();
      if (_current != null) _autoFollowIfNeeded(_current!, force: true);
    } else {
      _stopTracking();
    }
  }

  void _startTracking() {
    if (_posSub != null) return;
    if (_locLoading || _locError != null) return;

    if (_current != null) {
      _lastForDistance = _current;
      if (_trackPoints.isEmpty) _trackPoints.add(_current!);
    }

    const settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.best,
      distanceFilter: 1,
    );

    _posSub = geo.Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) {
        final ll = LatLng(pos.latitude, pos.longitude);
        final prev = _lastForDistance;
        _lastForDistance = ll;

        setState(() {
          _current = ll;

          if (prev != null) {
            final meters = _haversineMeters(prev, ll);


            if (meters >= 0.5 && meters <= 120) {
              _distanceKm += meters / 1000.0;

              final last = _trackPoints.isEmpty ? null : _trackPoints.last;
              if (last == null) {
                _trackPoints.add(ll);
              } else {
                final metersFromLast = _haversineMeters(last, ll);
                if (metersFromLast >= 2) _trackPoints.add(ll);
              }
            }
          }
        });

        _autoFollowIfNeeded(ll);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _locError = 'Błąd GPS: $e');
      },
    );
  }

  void _stopTracking() {
    _posSub?.cancel();
    _posSub = null;
    _lastForDistance = null;
  }

  void _autoFollowIfNeeded(LatLng ll, {bool force = false}) {
    if (!_followUser) return;
    if (!_mapReady) {
      _pendingMoveTo = ll;
      return;
    }

    final now = DateTime.now();
    if (!force && now.difference(_lastAutoMove).inMilliseconds < 250) return;
    _lastAutoMove = now;

    _safeMoveMap(ll, _mapController.camera.zoom);
  }

  void _safeMoveMap(LatLng ll, double zoom) {
    if (_mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(ll, zoom);
        } catch (_) {}
      });
    } else {
      _pendingMoveTo = ll;
    }
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;

    final sinDlat = math.sin(dLat / 2);
    final sinDlon = math.sin(dLon / 2);

    final aa = sinDlat * sinDlat +
        math.cos(lat1) * math.cos(lat2) * sinDlon * sinDlon;

    final c = 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
    return R * c;
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  String _formatPace() {
    if (_distanceKm <= 0.01) return '--:-- /km';
    final minutes = c.elapsed.inSeconds / 60.0;
    final pace = minutes / _distanceKm;
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round().clamp(0, 59);
    return '${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')} /km';
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
                      final toMove = _pendingMoveTo;
                      if (toMove != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          _mapController.move(toMove, 16);
                        });
                        _pendingMoveTo = null;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mini_strava',
                    ),
                    if (_trackPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _trackPoints,
                            strokeWidth: 4,
                          ),
                        ],
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

            DropdownButtonFormField<act.ActivityType>(
              initialValue: c.type,
              decoration: const InputDecoration(labelText: 'Typ aktywności'),
              items: const [
                DropdownMenuItem(value: act.ActivityType.run, child: Text('Bieg')),
                DropdownMenuItem(value: act.ActivityType.bike, child: Text('Rower')),
                DropdownMenuItem(value: act.ActivityType.walk, child: Text('Spacer')),
              ],
              onChanged: isIdle ? (v) => c.setType(v ?? act.ActivityType.run) : null,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Tempo',
                    value: _formatPace(),
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Dystans',
                    value: '${_distanceKm.toStringAsFixed(2)} km',
                    icon: Icons.route,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(_format(c.elapsed), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isIdle
                        ? () {
                      _distanceKm = 0.0;
                      _lastForDistance = null;
                      _trackPoints.clear();
                      if (_current != null) _trackPoints.add(_current!);

                      c.start();
                      if (_current != null) _autoFollowIfNeeded(_current!, force: true);

                      setState(() {});
                    }
                        : null,
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
                onPressed: (isRunning || isPaused)
                    ? () async {
                  _stopTracking();

                  await c.finish(
                    context,
                    distanceKm: _distanceKm,
                    track: _trackPoints
                        .map((p) => GpsPoint(lat: p.latitude, lng: p.longitude))
                        .toList(),
                  );
                }
                    : null,
                child: const Text('Zakończ i zapisz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
