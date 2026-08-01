import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart' show ShopLocation, DeliveryFeeTier;

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
  const DeliveryLocationResult({
    required this.latLng,
    required this.address,
    required this.distanceKm,
    required this.deliveryFee,
  });

  final LatLng latLng;
  final String address;
  final double distanceKm;
  final double deliveryFee;
}

double _feeForDistanceKm(double distanceKm, List<DeliveryFeeTier> tiers) {
  for (final tier in tiers) {
    if (distanceKm <= tier.maxKm) return tier.fee;
  }
  return tiers.isNotEmpty ? tiers.last.fee : 0;
}

/// Bounding box covering the Phnom Penh capital administrative boundary
/// (OSM relation 2199033), used as a fast local check for saved addresses
/// that predate the Phnom Penh-only home delivery restriction.
bool isLatLngWithinPhnomPenh(LatLng position) {
  return position.latitude >= 11.4200852 &&
      position.latitude <= 11.7349524 &&
      position.longitude >= 104.7204046 &&
      position.longitude <= 105.0373762;
}

class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
    this.shopLocation = ShopLocation.fallback,
    this.deliveryFeeTiers = const [
      DeliveryFeeTier(maxKm: 10, fee: 0),
      DeliveryFeeTier(maxKm: 15, fee: 2),
      DeliveryFeeTier(maxKm: 20, fee: 3),
      DeliveryFeeTier(maxKm: 25, fee: 5),
    ],
  });

  final LatLng? initialLocation;
  final String? initialAddress;
  final ShopLocation shopLocation;
  final List<DeliveryFeeTier> deliveryFeeTiers;

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  static const LatLng _phnomPenh = LatLng(11.5564, 104.9282);
  static const Distance _distanceCalculator = Distance();

  final MapController _mapController = MapController();
  LatLng _selectedPosition = _phnomPenh;
  LatLng? _currentLocation;
  String _selectedAddress = 'Move the map or tap to select a location';
  bool _isLocating = false;
  bool _isGeocoding = false;
  bool _isServiceableZone = true;
  String? _errorMessage;
  Timer? _mapMoveDebounce;
  StreamSubscription<Position>? _positionSubscription;
  bool _autoCentered = false;
  _MapStyle _mapStyle = _MapStyle.street;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  bool _showSearchResults = false;

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
    _searchDebounce?.cancel();
    _positionSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  LatLng get _shopLatLng =>
      LatLng(widget.shopLocation.lat, widget.shopLocation.lng);

  double get _distanceKmFromShop => _distanceCalculator.as(
    LengthUnit.Kilometer,
    _shopLatLng,
    _selectedPosition,
  );

  double get _currentDeliveryFee =>
      _feeForDistanceKm(_distanceKmFromShop, widget.deliveryFeeTiers);

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

  /// Cambodia's ISO 3166-2 subdivision code for the Phnom Penh capital.
  static const String _phnomPenhIsoCode = 'KH-12';

  bool _isPhnomPenhAddress(Map<String, dynamic>? address) {
    if (address == null) return false;
    final iso = address['ISO3166-2-lvl4']?.toString();
    if (iso == _phnomPenhIsoCode) return true;

    const candidateKeys = ['state', 'city', 'county', 'town', 'municipality'];
    for (final key in candidateKeys) {
      final value = address[key]?.toString() ?? '';
      if (value.contains('Phnom Penh') || value.contains('ភ្នំពេញ')) {
        return true;
      }
    }
    return false;
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
      final address = decoded is Map
          ? (decoded['address'] as Map?)?.cast<String, dynamic>()
          : null;
      final inZone = _isPhnomPenhAddress(address);

      setState(() {
        _selectedAddress = displayName?.isNotEmpty == true
            ? displayName!
            : _formatCoordinates(position);
        _isGeocoding = false;
        _isServiceableZone = inZone;
        if (!inZone) {
          _errorMessage = AppLocalizations.of(context).deliveryZonePhnomPenhOnly;
        }
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
    if (!_isServiceableZone) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).deliveryZonePhnomPenhOnly;
      });
      _showOutOfZoneDialog();
      return;
    }
    Navigator.of(context).pop(
      DeliveryLocationResult(
        latLng: _selectedPosition,
        address: _selectedAddress,
        distanceKm: _distanceKmFromShop,
        deliveryFee: _currentDeliveryFee,
      ),
    );
  }

  Future<void> _showOutOfZoneDialog() async {
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deliveryZoneNotAvailableTitle),
        content: Text(l.deliveryZonePhnomPenhOnly),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.ok),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'q': query,
        'limit': '6',
        'addressdetails': '1',
      });
      final res = await http
          .get(uri, headers: {'User-Agent': _osmUserAgent, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            _searchResults = decoded.cast<Map<String, dynamic>>();
            _showSearchResults = _searchResults.isNotEmpty;
            _isSearching = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
      _isSearching = false;
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.tryParse(result['lat']?.toString() ?? '');
    final lon = double.tryParse(result['lon']?.toString() ?? '');
    if (lat == null || lon == null) return;
    final target = LatLng(lat, lon);
    final address =
        result['display_name']?.toString() ?? _formatCoordinates(target);
    final resultAddressDetails = (result['address'] as Map?)
        ?.cast<String, dynamic>();
    final inZone = _isPhnomPenhAddress(resultAddressDetails);
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
      _selectedPosition = target;
      _selectedAddress = address;
      _isGeocoding = false;
      _isServiceableZone = inZone;
      _errorMessage = inZone
          ? null
          : AppLocalizations.of(context).deliveryZonePhnomPenhOnly;
    });
    _moveTo(target, zoom: 16);
  }

  void _dismissSearch() {
    _searchFocusNode.unfocus();
    setState(() => _showSearchResults = false);
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
    final l = AppLocalizations.of(context);
    final infoText = _isGeocoding ? l.loading : _selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.selectAddress),
        actions: [
          TextButton(onPressed: _confirmSelection, child: Text(l.ok)),
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
              onTap: (_, point) {
                _dismissSearch();
                _updateSelectedPosition(point);
              },
            ),
            children: [
              ..._buildMapLayers(),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_shopLatLng, _selectedPosition],
                    strokeWidth: 3,
                    color: const Color(0xFF0F6BFF).withValues(alpha: 0.75),
                    isDotted: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 90,
                    height: 58,
                    point: _shopLatLng,
                    alignment: Alignment.topCenter,
                    child: _ShopPin(name: widget.shopLocation.name),
                  ),
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
                      HugeIcons.strokeRoundedPin02,
                      size: 46,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01, size: 20),
                                suffixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(HugeIcons.strokeRoundedCancel01, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchResults = [];
                                            _showSearchResults = false;
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              onChanged: _onSearchChanged,
                              onTap: () {
                                if (_searchResults.isNotEmpty) {
                                  setState(() => _showSearchResults = true);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MapStyleSwitch(
                          mapStyle: _mapStyle,
                          onStreetSelected: _mapStyle == _MapStyle.street
                              ? null
                              : () => setState(
                                  () => _mapStyle = _MapStyle.street,
                                ),
                          onSatelliteSelected: _mapStyle == _MapStyle.satellite
                              ? null
                              : () => setState(
                                  () => _mapStyle = _MapStyle.satellite,
                                ),
                        ),
                      ],
                    ),
                    if (_showSearchResults && _searchResults.isNotEmpty)
                      Material(
                        elevation: 6,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 260),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final r = _searchResults[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  HugeIcons.strokeRoundedLocation01,
                                  size: 20,
                                  color: Color(0xFF0F6BFF),
                                ),
                                title: Text(
                                  r['display_name']?.toString() ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                onTap: () => _selectSearchResult(r),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
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
            child: _MapFab(
              heroTag: 'current-location',
              icon: HugeIcons.strokeRoundedGps02,
              onPressed: _isLocating ? null : _moveToCurrentLocation,
              isLoading: _isLocating,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _BottomSheetCard(
              title: l.deliveryAddress,
              subtitle: infoText,
              helper:
                  'Drag the map, tap to drop a pin, or use your current location.',
              errorMessage: _errorMessage,
              onConfirm: _confirmSelection,
              confirmLabel: l.confirm,
              distanceKm: _distanceKmFromShop,
              deliveryFee: _currentDeliveryFee,
              showDistance: _isServiceableZone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed marker showing the shop's verified location, so the user can
/// visually confirm this is the correct shop before dropping their pin.
class _ShopPin extends StatelessWidget {
  const _ShopPin({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            HugeIcons.strokeRoundedStore01,
            size: 16,
            color: Colors.white,
          ),
        ),
      ],
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
    required this.confirmLabel,
    required this.distanceKm,
    required this.deliveryFee,
    required this.showDistance,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final String helper;
  final String? errorMessage;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final double distanceKm;
  final double deliveryFee;
  final bool showDistance;

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
          if (showDistance) ...[
            const SizedBox(height: 8),
            _DistanceFeeBadge(distanceKm: distanceKm, deliveryFee: deliveryFee),
          ],
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
              child: Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceFeeBadge extends StatelessWidget {
  const _DistanceFeeBadge({required this.distanceKm, required this.deliveryFee});

  final double distanceKm;
  final double deliveryFee;

  @override
  Widget build(BuildContext context) {
    final isFree = deliveryFee <= 0;
    final color = isFree ? const Color(0xFF16A34A) : const Color(0xFF0F6BFF);
    final feeText = isFree
        ? 'Free delivery'
        : '\$${deliveryFee.toStringAsFixed(2)} delivery fee';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(HugeIcons.strokeRoundedRoute01, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '${distanceKm.toStringAsFixed(1)} km from shop · $feeText',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
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
              icon: HugeIcons.strokeRoundedMapsLocation01,
              label: 'Map',
              selected: mapStyle == _MapStyle.street,
              onTap: onStreetSelected,
            ),
            const SizedBox(width: 4),
            _MapStyleButton(
              icon: HugeIcons.strokeRoundedSatellite01,
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
