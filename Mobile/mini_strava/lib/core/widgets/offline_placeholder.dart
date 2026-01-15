import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/navigation/app_routes.dart';

class OfflinePlaceholder extends StatefulWidget {
  final String message;
  final String? subtitle;


  final Future<void> Function()? onRetry;

  const OfflinePlaceholder({
    super.key,
    this.message = 'Nie załadowano strony',
    this.subtitle,
    this.onRetry,
  });

  @override
  State<OfflinePlaceholder> createState() => _OfflinePlaceholderState();
}

class _OfflinePlaceholderState extends State<OfflinePlaceholder> {
  bool _loading = true;
  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  bool _hasAnyNetwork(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _checkInternet() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final results = await Connectivity().checkConnectivity();
    final hasNetwork = _hasAnyNetwork(results);

    bool hasInternet = false;
    if (hasNetwork) {
      try {
        final r = await InternetAddress.lookup('example.com')
            .timeout(const Duration(seconds: 2));
        hasInternet = r.isNotEmpty && r.first.rawAddress.isNotEmpty;
      } catch (_) {
        hasInternet = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _hasInternet = hasInternet;
      _loading = false;
    });
  }

  Future<void> _retry() async {

    await _checkInternet();

    await widget.onRetry?.call();
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle ??
        (_hasInternet ? 'Sprawdź połączenie z internetem.' : 'Brak połączenia z internetem.');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Wróć',
          onPressed: () => _goBack(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 44),
              const SizedBox(height: 12),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retry,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
