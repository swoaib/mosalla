import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _hasPermissions = false;
  double? _qiblaBearing;
  CompassEvent? _lastCompassEvent;
  String _errorMessage = '';
  
  // Mecca Coordinates
  final double meccaLat = 21.422487;
  final double meccaLon = 39.826206;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    try {
      // 1. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)!.locationPermissionsDenied;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.locationPermissionsPermanentlyDenied;
          });
        }
        return;
      }

      // 2. We have permissions
      setState(() {
        _hasPermissions = true;
      });

      // 3. Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      // 4. Calculate Qibla Bearing
      _calculateQiblaDirection(position.latitude, position.longitude);

      // 5. Start listening to Compass
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            _lastCompassEvent = event;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _calculateQiblaDirection(double lat1, double lon1) {
    double lat1Rad = lat1 * (math.pi / 180.0);
    double lon1Rad = lon1 * (math.pi / 180.0);
    double lat2Rad = meccaLat * (math.pi / 180.0);
    double lon2Rad = meccaLon * (math.pi / 180.0);

    double dLon = lon2Rad - lon1Rad;

    double y = math.sin(dLon) * math.cos(lat2Rad);
    double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    double brng = math.atan2(y, x);
    brng = brng * (180.0 / math.pi);
    brng = (brng + 360.0) % 360.0;

    setState(() {
      _qiblaBearing = brng;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.qiblaCompass)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _initQibla,
                  child: Text(l10n.retry),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (!_hasPermissions || _qiblaBearing == null || _lastCompassEvent == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.qiblaCompass)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(l10n.calibratingCompassLocation)
            ],
          ),
        ),
      );
    }

    // Compass heading is the angle the device is pointed at
    double heading = _lastCompassEvent!.heading ?? 0;
    
    // Rotation calculations
    // Calculate how much to rotate the compass background so North is correctly oriented
    double compassRotation = -heading * (math.pi / 180);
    
    // Calculate how much to rotate the Qibla needle relative to the phone's heading
    double qiblaRotation = (_qiblaBearing! - heading) * (math.pi / 180);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qiblaDirection, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Display bearing text
            Text(
              '${_qiblaBearing!.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              l10n.bearingToMakkah,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            // Compass UI
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass Ring
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        width: 16,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 10,
                        )
                      ]
                    ),
                  ),
                  
                  // North Pointer (Rotating Compass Background)
                  Transform.rotate(
                    angle: compassRotation,
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            child: Column(
                              children: [
                                Text(l10n.northShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                                Container(width: 2, height: 10, color: Colors.red),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Column(
                              children: [
                                Container(width: 2, height: 10, color: Colors.grey),
                                Text(l10n.southShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: Row(
                              children: [
                                Text(l10n.westShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                                Container(width: 10, height: 2, color: Colors.grey),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Row(
                              children: [
                                Container(width: 10, height: 2, color: Colors.grey),
                                Text(l10n.eastShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Qibla Indicator Needle
                  Transform.rotate(
                    angle: qiblaRotation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                          shadows: const [Shadow(blurRadius: 10, color: Colors.black26)],
                        ),
                        Container(
                          width: 4,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)]
                          ),
                        ),
                        // Offset so the needle rotates around its bottom base correctly
                        const SizedBox(height: 160), 
                      ],
                    ),
                  ),
                  
                  // Center dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)]
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
