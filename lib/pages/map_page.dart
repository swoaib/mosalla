import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:geolocator/geolocator.dart';
import '../providers/prayer_time_provider.dart';
import '../model/mosalla_data.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Map<MarkerId, Marker> _markers = {};
  bool _isLocating = false;
  bool _isMapReady = false;

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  String _generateMapStyle(Color bgColor, {required bool isDark}) {
    final bgHex = _colorToHex(bgColor);
    final textHex = isDark ? '#BDBDBD' : '#333333';
    final roadHex = isDark ? '#2C2C2C' : '#D6D6D6';

    return '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "$bgHex"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "$textHex"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "$bgHex"}]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [{"color": "$textHex"}, {"visibility": "simplified"}]
      },
      {
        "featureType": "administrative",
        "elementType": "labels",
        "stylers": [{"visibility": "simplified"}]
      },
      {
        "featureType": "administrative.neighborhood",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "poi",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "transit",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "$roadHex"}]
      },
      {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [{"visibility": "simplified"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.icon",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [{"visibility": "simplified"}, {"weight": 0.5}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "${isDark ? '#000000' : '#C9EAFF'}"}]
      }
    ]
    ''';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMarkers();
  }

  void _loadMarkers() {
    final provider = context.read<PrayerTimeProvider>();
    final primaryColor = Theme.of(context).primaryColor;
    final primaryHue = HSVColor.fromColor(primaryColor).hue;

    final markers = <MarkerId, Marker>{};
    for (var mosalla in provider.mosallas) {
      if (mosalla.hasCoordinates) {
        final markerId = MarkerId(mosalla.id);
        final marker = Marker(
          markerId: markerId,
          position: LatLng(mosalla.latitude!, mosalla.longitude!),
          onTap: () => _showMosqueDetails(mosalla),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              primaryHue), // Dynamically matches app theme
        );
        markers[markerId] = marker;
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _fitBounds();

    // Add a slight delay before revealing the map to allow the dark style
    // to apply, avoiding a flash of the default light map.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    });
  }

  String? _getMapStyle() {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _generateMapStyle(bgColor, isDark: isDark);
  }

  Future<void> _fitBounds() async {
    if (_markers.isEmpty) return;

    final controller = await _controller.future;

    double? minLat, maxLat, minLng, maxLng;

    for (var marker in _markers.values) {
      if (minLat == null || marker.position.latitude < minLat) {
        minLat = marker.position.latitude;
      }
      if (maxLat == null || marker.position.latitude > maxLat) {
        maxLat = marker.position.latitude;
      }
      if (minLng == null || marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (maxLng == null || marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50.0, // padding
        ),
      );
    }
  }

  void _showMosqueDetails(MosallaData mosalla) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mosalla.logo != null && mosalla.logo!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          mosalla.logo!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.mosque, size: 40),
                        ),
                      )
                    else
                      const Icon(Icons.mosque, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosalla.localizedName(l10n.localeName),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mosalla.location,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchMap(mosalla),
                    icon: const Icon(Icons.directions),
                    label: Text(l10n.getDirections),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _centerOnUserLocation() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are permanently denied, we cannot request permissions.'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _launchMap(MosallaData mosalla) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      await availableMaps.first.showDirections(
        destination: launcher.Coords(mosalla.latitude!, mosalla.longitude!),
        destinationTitle: mosalla.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    const bottomNavHeight = 55.0; // CustomBottomNavigationBar.height
    final bottomNavPadding = isAndroid ? 16.0 : 0.0;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final totalBottomPadding = bottomNavHeight +
        bottomNavPadding +
        safeAreaBottom +
        16.0; // Adding 16 for extra breathing room

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            style: _getMapStyle(),
            initialCameraPosition: _markers.values.isNotEmpty
                ? CameraPosition(
                    target: _markers.values.first.position,
                    zoom: 12,
                  )
                : const CameraPosition(
                    target: LatLng(35.6895, 139.6917), // Tokyo default
                    zoom: 10,
                  ),
            onMapCreated: _onMapCreated,
            markers: _markers.values.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            padding: EdgeInsets.only(
                bottom: totalBottomPadding), // Calculated dynamically
          ),
          // Overlay to hide the map while it loads its styles to prevent flashes
          IgnorePointer(
            ignoring: _isMapReady,
            child: AnimatedOpacity(
              opacity: _isMapReady ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(child: SizedBox.shrink()),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: totalBottomPadding,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.8)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLocating ? null : _centerOnUserLocation,
                  borderRadius: BorderRadius.circular(30),
                  child: Center(
                    child: _isLocating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.my_location,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
