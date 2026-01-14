import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

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
  final GlobalKey _mapShotKey = GlobalKey();

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

  Timer? _avgSpeedTimer;
  double _avgSpeedKmH = 0.0;

  StreamSubscription<geo.Position>? _calibSub;
  Timer? _calibTimeout;

  bool _isCalibrating = false;
  bool _gpsLocked = false;
  final List<geo.Position> _calibSamples = [];

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
    _avgSpeedTimer?.cancel();
    _posSub?.cancel();
    _stopCalibration();

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
      _beginCalibration();
      _syncTrackingWithState();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locError = 'Nie udało się pobrać lokalizacji: $e';
        _locLoading = false;
      });
    }
  }

  void _beginCalibration() {
    if (_locLoading || _locError != null) return;
    if (_isCalibrating) return;

    _stopCalibration();
    _isCalibrating = true;
    _gpsLocked = false;
    _calibSamples.clear();

    const settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.best,
      distanceFilter: 0,
    );

    _calibSub = geo.Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      if (pos.accuracy.isNaN) return;
      if (pos.accuracy <= 0) return;

      if (pos.accuracy <= 25) {
        _calibSamples.add(pos);
      }

      if (_calibSamples.length >= 6) {
        _finalizeCalibration();
      } else {
        setState(() {
          _current = LatLng(pos.latitude, pos.longitude);
        });
      }
    }, onError: (e) {
      if (!mounted) return;
      setState(() => _locError = 'Błąd GPS: $e');
    });

    _calibTimeout = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      _finalizeCalibration(fallback: true);
    });
  }

  void _stopCalibration() {
    _calibTimeout?.cancel();
    _calibTimeout = null;

    _calibSub?.cancel();
    _calibSub = null;

    _isCalibrating = false;
  }

  void _finalizeCalibration({bool fallback = false}) {
    if (!_isCalibrating) return;

    LatLng? ll;

    if (_calibSamples.isNotEmpty) {
      final sorted = List<geo.Position>.from(_calibSamples)
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
      final take = sorted.take(math.min(5, sorted.length)).toList();

      final lat =
          take.map((p) => p.latitude).reduce((a, b) => a + b) / take.length;
      final lng =
          take.map((p) => p.longitude).reduce((a, b) => a + b) / take.length;

      ll = LatLng(lat, lng);
    } else if (fallback && _current != null) {
      ll = _current;
    }

    _stopCalibration();

    if (ll != null) {
      setState(() {
        _current = ll;
        _gpsLocked = true;
      });
      _safeMoveMap(ll, 16);
    } else {
      setState(() {
        _gpsLocked = false;
      });
    }
  }

  void _syncTrackingWithState() {
    final isRunning = c.state == ActivityState.running;
    _followUser = isRunning;

    if (isRunning) {
      if (!_gpsLocked) {
        _beginCalibration();
        return;
      }
      _startTracking();
      _startAvgSpeedTimer();
      if (_current != null) _autoFollowIfNeeded(_current!, force: true);
    } else {
      _stopTracking();
      _stopAvgSpeedTimer();
    }
  }

  void _startAvgSpeedTimer() {
    if (_avgSpeedTimer != null) return;
    _avgSpeedTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      final seconds = c.elapsed.inSeconds;
      if (seconds <= 0 || _distanceKm <= 0.001) {
        setState(() => _avgSpeedKmH = 0.0);
        return;
      }

      final hours = seconds / 3600.0;
      final v = _distanceKm / hours;

      setState(() => _avgSpeedKmH = v.isFinite ? v : 0.0);
    });
  }

  void _stopAvgSpeedTimer() {
    _avgSpeedTimer?.cancel();
    _avgSpeedTimer = null;
  }

  void _startTracking() {
    if (_posSub != null) return;
    if (_locLoading || _locError != null) return;
    if (!_gpsLocked) return;

    if (_current != null) {
      _lastForDistance = _current;
      if (_trackPoints.isEmpty) _trackPoints.add(_current!);
    }

    const settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.best,
      distanceFilter: 1,
    );

    _posSub = geo.Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      final ll = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _current = ll;
      });

      if (!_gpsLocked) {
        _lastForDistance = ll;
        return;
      }

      final prev = _lastForDistance;
      _lastForDistance = ll;

      if (prev != null) {
        final meters = _haversineMeters(prev, ll);
        if (meters >= 0.5 && meters <= 120) {
          setState(() {
            _distanceKm += meters / 1000.0;

            final last = _trackPoints.isEmpty ? null : _trackPoints.last;
            if (last == null) {
              _trackPoints.add(ll);
            } else {
              final metersFromLast = _haversineMeters(last, ll);
              if (metersFromLast >= 2) _trackPoints.add(ll);
            }
          });
        }
      }

      _autoFollowIfNeeded(ll);
    }, onError: (e) {
      if (!mounted) return;
      setState(() => _locError = 'Błąd GPS: $e');
    });
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
    const r = 6371000.0;
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;

    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;

    final sinDlat = math.sin(dLat / 2);
    final sinDlon = math.sin(dLon / 2);

    final aa = sinDlat * sinDlat +
        math.cos(lat1) * math.cos(lat2) * sinDlon * sinDlon;

    final cc = 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
    return r * cc;
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  String _formatPace() {
    if (_distanceKm <= 0.01) return '--:-- min/km';
    final minutes = c.elapsed.inSeconds / 60.0;
    final pace = minutes / _distanceKm;
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round().clamp(0, 59);
    return '${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')} min/km';
  }

  String _formatSpeed() {
    final seconds = c.elapsed.inSeconds;
    if (seconds <= 0 || _distanceKm <= 0.001) return '0.0 km/h';
    final hours = seconds / 3600.0;
    final v = _distanceKm / hours;
    return '${(v.isFinite ? v : 0.0).toStringAsFixed(1)} km/h';
  }


  Future<String?> _captureRouteImage() async {
    try {
      final renderObject = _mapShotKey.currentContext?.findRenderObject();
      final boundary = renderObject is RenderRepaintBoundary ? renderObject : null;
      if (boundary == null) return null;


      final pixelRatio =
          ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();


      final dir = await getApplicationDocumentsDirectory();
      final routesDir = Directory('${dir.path}/routes');
      if (!await routesDir.exists()) {
        await routesDir.create(recursive: true);
      }

      final file = File(
          '${routesDir.path}/route_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
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
                    : RepaintBoundary(
                  key: _mapShotKey,
                  child: FlutterMap(
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
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.mini_strava',
                      ),
                      if (_trackPoints.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(points: _trackPoints, strokeWidth: 4),
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
                      if (_isCalibrating || !_gpsLocked)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Kalibracja GPS',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                    icon: Icons.av_timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Prędkość',
                    value: _formatSpeed(),
                    icon: Icons.speed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Dystans',
                    value: '${_distanceKm.toStringAsFixed(2)} km',
                    icon: Icons.route,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Śr. prędkość',
                    value: '${_avgSpeedKmH.toStringAsFixed(1)} km/h',
                    icon: Icons.speed_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _format(c.elapsed),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isIdle && !_locLoading && _locError == null)
                        ? () {
                      _distanceKm = 0.0;
                      _avgSpeedKmH = 0.0;
                      _lastForDistance = null;
                      _trackPoints.clear();

                      if (!_gpsLocked) {
                        _beginCalibration();
                        return;
                      }

                      if (_current != null) {
                        _trackPoints.add(_current!);
                        _lastForDistance = _current;
                      }

                      c.start();
                      if (_current != null) {
                        _autoFollowIfNeeded(_current!, force: true);
                      }
                      setState(() {});
                    }
                        : null,
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRunning
                        ? c.pause
                        : (isPaused
                        ? () {
                      if (!_gpsLocked) {
                        _beginCalibration();
                        return;
                      }
                      if (_current != null) _lastForDistance = _current;
                      c.resume();
                    }
                        : null),
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

                  final controller = c;
                  final distance = _distanceKm;
                  final track = _trackPoints
                      .map((p) => GpsPoint(lat: p.latitude, lng: p.longitude))
                      .toList();

                  _stopTracking();
                  _stopAvgSpeedTimer();

                  final routeImagePath = await _captureRouteImage();

                  if (!context.mounted) return;

                  await controller.finish(
                    context,
                    distanceKm: distance,
                    track: track,
                    routeImagePath: routeImagePath,
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
