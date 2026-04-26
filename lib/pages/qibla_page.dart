import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
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
  int? _lastVibratedHeading;
  bool _isAligned = false;
  String? _currentCity;

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
              _errorMessage =
                  AppLocalizations.of(context)!.locationPermissionsDenied;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!
                .locationPermissionsPermanentlyDenied;
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
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      // 4. Calculate Qibla Bearing
      _calculateQiblaDirection(position.latitude, position.longitude);

      // 5. Get City Name (Reverse Geocoding)
      _getCityName(position.latitude, position.longitude);

      // 6. Start listening to Compass
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          if (event.heading != null && _qiblaBearing != null) {
            double currentHeading = event.heading!;
            int currentHeadingInt = currentHeading.round();

            // Calculate absolute difference between heading and qibla
            double diff = (currentHeading - _qiblaBearing!).abs();
            if (diff > 180.0) diff = 360.0 - diff;

            bool currentlyAligned = diff <= 2.0; // 2 degrees tolerance

            if (currentlyAligned && !_isAligned) {
              HapticFeedback.heavyImpact();
              _isAligned = true;
            } else if (!currentlyAligned) {
              _isAligned = false;

              if (_lastVibratedHeading == null) {
                _lastVibratedHeading = currentHeadingInt;
              } else {
                int headingDiff =
                    (currentHeadingInt - _lastVibratedHeading!).abs();
                if (headingDiff > 180) headingDiff = 360 - headingDiff;

                // Light tick every 3 degrees of rotation for better feel
                if (headingDiff >= 3) {
                  HapticFeedback.selectionClick();
                  _lastVibratedHeading = currentHeadingInt;
                }
              }
            }
          }

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

  Future<void> _getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _currentCity = place.locality ??
                place.subAdministrativeArea ??
                place.administrativeArea;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching city: $e");
    }
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
                Text(_errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
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

    if (!_hasPermissions ||
        _qiblaBearing == null ||
        _lastCompassEvent == null) {
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

    // Calculate which way to turn
    double diff = _qiblaBearing! - heading;
    if (diff > 180.0) {
      diff -= 360.0;
    } else if (diff < -180.0) {
      diff += 360.0;
    }

    bool isFacing = diff.abs() <= 2.0;
    String turnText;
    if (isFacing) {
      turnText = l10n.facingMakkah;
    } else if (diff > 0) {
      turnText = l10n.turnRight;
    } else {
      turnText = l10n.turnLeft;
    }

    double displayHeading = heading % 360;
    if (displayHeading < 0) displayHeading += 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qiblaDirection,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            if (_currentCity != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        size: 24, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _currentCity!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Display realtime heading text
            Text(
              '${displayHeading.toStringAsFixed(0)}°',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              turnText,
              style: TextStyle(
                fontSize: 22,
                color: isFacing ? Colors.amber : Colors.grey,
                fontWeight: isFacing ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isFacing ? Colors.amber : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
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
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          width: 16,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 10,
                          )
                        ]),
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
                                Text(l10n.northShort,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.red)),
                                Container(
                                    width: 2, height: 10, color: Colors.red),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Column(
                              children: [
                                Container(
                                    width: 2, height: 10, color: Colors.grey),
                                Text(l10n.southShort,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: Row(
                              children: [
                                Text(l10n.westShort,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.grey)),
                                Container(
                                    width: 10, height: 2, color: Colors.grey),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Row(
                              children: [
                                Container(
                                    width: 10, height: 2, color: Colors.grey),
                                Text(l10n.eastShort,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.grey)),
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
                        // Kaaba Icon
                        Container(
                          width: 30,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black45,
                                    offset: Offset(0, 4))
                              ]),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 5,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        CustomPaint(
                          size: const Size(30, 80),
                          painter: QiblaNeedlePainter(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        // Offset so the needle rotates around its bottom base correctly
                        const SizedBox(height: 115),
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
                        boxShadow: const [
                          BoxShadow(blurRadius: 5, color: Colors.black26)
                        ]),
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

class QiblaNeedlePainter extends CustomPainter {
  final Color color;

  QiblaNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();

    // Tapered pill shape (rounded rectangle narrowing on pointing side)
    final double bottomWidth = size.width * 0.8;
    final double topWidth = size.width * 0.3;
    final double topRadius = topWidth / 2;
    final double bottomRadius = bottomWidth / 2;

    path.moveTo(size.width / 2 - topRadius, topRadius);

    // Top arc (pointing side)
    path.arcToPoint(
      Offset(size.width / 2 + topRadius, topRadius),
      radius: Radius.circular(topRadius),
      clockwise: true,
    );

    // Right edge tapering down
    path.lineTo(size.width / 2 + bottomRadius, size.height - bottomRadius);

    // Bottom arc
    path.arcToPoint(
      Offset(size.width / 2 - bottomRadius, size.height - bottomRadius),
      radius: Radius.circular(bottomRadius),
      clockwise: true,
    );

    path.close();

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw subtle shadow
    canvas.drawShadow(path, Colors.black45, 4.0, false);

    // Draw shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant QiblaNeedlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
