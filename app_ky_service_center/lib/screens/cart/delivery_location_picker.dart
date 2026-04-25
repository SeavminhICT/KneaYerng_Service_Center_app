import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const String _osmUserAgent = 'KYServiceCenterApp/1.0 (support@kneyerng.app)';
const String _streetTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String _satelliteTileUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/'
    'World_Imagery/MapServer/tile/{z}/{y}/{x}';
const String _satelliteLabelsTileUrl =
    'https://services.arcgisonline.com/ArcGIS/rest/services/'
    'Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';

enum _MapStyle { street, satellite }

class DeliveryLocationResult {
  const DeliveryLocationResult({required this.latLng, required this.address});

  final LatLng latLng;
  final String address;
}

class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  final LatLng? initialLocation;
  final String? initialAddress;

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  static const LatLng _phnomPenh = LatLng(11.5564, 104.9282);

  final MapController _mapController = MapController();
  LatLng _selectedPosition = _phnomPenh;
  LatLng? _currentLocation;
  String _selectedAddress = 'Move the map or tap to select a location';
  bool _isLocating = false;
  bool _isGeocoding = false;
  String? _errorMessage;
  Timer? _mapMoveDebounce;
  StreamSubscription<Position>? _positionSubscription;
  bool _autoCentered = false;
  _MapStyle _mapStyle = _MapStyle.street;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialLocation ?? _phnomPenh;
    if (widget.initialAddress != null &&
        widget.initialAddress!.trim().isNotEmpty) {
      _selectedAddress = widget.initialAddress!.trim();
    }
    _checkPermission();
  }

  @override
  void dispose() {
    _mapMoveDebounce?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _startLocationTracking();
    }
  }

  LocationSettings get _locationSettings => const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 5,
  );

  void _startLocationTracking() {
    _positionSubscription ??=
        Geolocator.getPositionStream(
          locationSettings: _locationSettings,
        ).listen((position) {
          if (!mounted) return;
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
        }, onError: (_) {});
  }

  Future<Position?> _resolveCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() {
        _errorMessage = 'Location services are disabled.';
      });
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permission is required.';
      });
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _errorMessage = null;
      _isLocating = true;
    });

    try {
      final position = await _resolveCurrentPosition();
      if (position == null) {
        setState(() {
          _errorMessage = 'Unable to get current location.';
        });
        return;
      }

      final target = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = target;
      });
      _moveTo(target);
      _updateSelectedPosition(target);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to get current location.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _moveTo(LatLng target, {double zoom = 16}) {
    _mapController.move(target, zoom);
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _reverseGeocode(position);
  }

  void _scheduleReverseGeocode(
    LatLng position, {
    Duration delay = const Duration(milliseconds: 450),
  }) {
    _mapMoveDebounce?.cancel();
    setState(() {
      _isGeocoding = true;
      _errorMessage = null;
    });
    _mapMoveDebounce = Timer(delay, () {
      _reverseGeocode(position);
    });
  }

  void _handleMapPositionChanged(MapPosition position, bool hasGesture) {
    if (!hasGesture || position.center == null) return;
    final center = position.center!;
    setState(() {
      _selectedPosition = center;
    });
    _scheduleReverseGeocode(center);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() {
      _isGeocoding = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'addressdetails': '1',
      });

      final res = await http
          .get(
            uri,
            headers: {
              'User-Agent': _osmUserAgent,
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() {
          _selectedAddress = _formatCoordinates(position);
          _isGeocoding = false;
        });
        return;
      }

      final decoded = jsonDecode(res.body);
      final displayName = decoded is Map
          ? decoded['display_name']?.toString()
          : null;

      setState(() {
        _selectedAddress = displayName?.isNotEmpty == true
            ? displayName!
            : _formatCoordinates(position);
        _isGeocoding = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress = _formatCoordinates(position);
        _isGeocoding = false;
      });
    }
  }

  String _formatCoordinates(LatLng position) {
    return 'Lat:${position.latitude.toStringAsFixed(6)}, '
        'Lng:${position.longitude.toStringAsFixed(6)}';
  }

  void _confirmSelection() {
    Navigator.of(context).pop(
      DeliveryLocationResult(
        latLng: _selectedPosition,
        address: _selectedAddress,
      ),
    );
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyle = _mapStyle == _MapStyle.street
          ? _MapStyle.satellite
          : _MapStyle.street;
    });
  }

  List<Widget> _buildMapLayers() {
    switch (_mapStyle) {
      case _MapStyle.street:
        return [
          TileLayer(
            urlTemplate: _streetTileUrl,
            userAgentPackageName: 'com.kneayerng.app_ky_service_center',
            maxZoom: 19,
          ),
        ];
      case _MapStyle.satellite:
        return [
          TileLayer(
            urlTemplate: _satelliteTileUrl,
            userAgentPackageName: 'com.kneayerng.app_ky_service_center',
            maxZoom: 19,
          ),
          TileLayer(
            urlTemplate: _satelliteLabelsTileUrl,
            userAgentPackageName: 'com.kneayerng.app_ky_service_center',
            maxZoom: 19,
            tileDisplay: const TileDisplay.fadeIn(),
          ),
        ];
    }
  }

  String get _mapAttributionLabel {
    switch (_mapStyle) {
      case _MapStyle.street:
        return 'Map data: OpenStreetMap';
      case _MapStyle.satellite:
        return 'Imagery: Esri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoText = _isGeocoding ? 'Finding address...' : _selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton(onPressed: _confirmSelection, child: const Text('Use')),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                if (!_autoCentered && widget.initialLocation == null) {
                  _autoCentered = true;
                  _moveToCurrentLocation();
                }
              },
              onPositionChanged: _handleMapPositionChanged,
              onTap: (_, point) => _updateSelectedPosition(point),
            ),
            children: [
              ..._buildMapLayers(),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      width: 30,
                      height: 30,
                      point: _currentLocation!,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.18),
                        ),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Marker(
                    width: 46,
                    height: 46,
                    point: _selectedPosition,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_pin,
                      size: 46,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: _MapStyleSwitch(
                  mapStyle: _mapStyle,
                  onStreetSelected: _mapStyle == _MapStyle.street
                      ? null
                      : () => setState(() => _mapStyle = _MapStyle.street),
                  onSatelliteSelected: _mapStyle == _MapStyle.satellite
                      ? null
                      : () => setState(() => _mapStyle = _MapStyle.satellite),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 132,
            child: _AttributionBadge(label: _mapAttributionLabel),
          ),
          Positioned(
            right: 16,
            bottom: 150,
            child: Column(
              children: [
                _MapFab(
                  heroTag: 'current-location',
                  icon: Icons.my_location,
                  onPressed: _isLocating ? null : _moveToCurrentLocation,
                  isLoading: _isLocating,
                ),
                const SizedBox(height: 10),
                _MapFab(
                  heroTag: 'map-style-toggle',
                  icon: _mapStyle == _MapStyle.street
                      ? Icons.satellite_alt_outlined
                      : Icons.map_outlined,
                  onPressed: _toggleMapStyle,
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _BottomSheetCard(
              title: 'Delivery Location',
              subtitle: infoText,
              helper:
                  'Drag the map, tap to drop a pin, or use your current location.',
              errorMessage: _errorMessage,
              onConfirm: _confirmSelection,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String heroTag;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F6BFF),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  const _BottomSheetCard({
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.onConfirm,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final String helper;
  final String? errorMessage;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF4B5563))),
          const SizedBox(height: 6),
          Text(
            helper,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              errorMessage ?? '',
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Use this location'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributionBadge extends StatelessWidget {
  const _AttributionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _MapStyleSwitch extends StatelessWidget {
  const _MapStyleSwitch({
    required this.mapStyle,
    required this.onStreetSelected,
    required this.onSatelliteSelected,
  });

  final _MapStyle mapStyle;
  final VoidCallback? onStreetSelected;
  final VoidCallback? onSatelliteSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MapStyleButton(
              icon: Icons.map_outlined,
              label: 'Map',
              selected: mapStyle == _MapStyle.street,
              onTap: onStreetSelected,
            ),
            const SizedBox(width: 4),
            _MapStyleButton(
              icon: Icons.satellite_alt_outlined,
              label: 'Satellite',
              selected: mapStyle == _MapStyle.satellite,
              onTap: onSatelliteSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStyleButton extends StatelessWidget {
  const _MapStyleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F6BFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF111827),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
