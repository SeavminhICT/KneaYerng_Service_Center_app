import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../services/maps_config.dart';

class DeliveryLocationResult {
  const DeliveryLocationResult({
    required this.latLng,
    required this.address,
  });

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

  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng _selectedPosition = _phnomPenh;
  String _selectedAddress = 'Move the map or tap to select a location';
  bool _isLocating = false;
  bool _isGeocoding = false;
  bool _hasLocationPermission = false;
  String? _errorMessage;
  bool _isSearching = false;
  Timer? _debounce;
  List<_PlacePrediction> _predictions = [];
  bool _suppressSearch = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialLocation ?? _phnomPenh;
    if (widget.initialAddress != null &&
        widget.initialAddress!.trim().isNotEmpty) {
      _selectedAddress = widget.initialAddress!.trim();
      _searchController.text = widget.initialAddress!.trim();
    }
    _searchController.addListener(_onSearchChanged);
    _checkPermission();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
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
    if (!mounted) return;
    setState(() {
      _hasLocationPermission =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _errorMessage = null;
      _isLocating = true;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLocating = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission is required.';
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final target = LatLng(position.latitude, position.longitude);
      await _animateCamera(target);
      _updateSelectedPosition(target);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to get current location.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _hasLocationPermission = true;
      });
    }
  }

  Future<void> _animateCamera(LatLng target) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _predictions = [];
    });
    FocusScope.of(context).unfocus();
    _reverseGeocode(position);
  }

  void _onSearchChanged() {
    if (_suppressSearch) {
      _suppressSearch = false;
      return;
    }
    final query = _searchController.text.trim();
    _debounce?.cancel();
    if (query.length < 3) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPlacePredictions(query);
    });
  }

  Future<void> _fetchPlacePredictions(String query) async {
    if (MapsConfig.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      setState(() {
        _errorMessage = 'Set Google Maps API key to enable search.';
        _predictions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
    ).replace(queryParameters: {
      'input': query,
      'key': MapsConfig.googleMapsApiKey,
      'components': 'country:kh',
      'language': 'en',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(res.body);
      final status = decoded['status']?.toString();
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        setState(() {
          _errorMessage = decoded['error_message']?.toString() ??
              'Search failed. Please try again.';
          _predictions = [];
          _isSearching = false;
        });
        return;
      }

      final raw = decoded['predictions'];
      final predictions = raw is List
          ? raw
              .whereType<Map>()
              .map((item) => _PlacePrediction.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((item) => item.placeId.isNotEmpty)
              .toList()
          : <_PlacePrediction>[];

      setState(() {
        _predictions = predictions;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to search address.';
        _predictions = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectPrediction(_PlacePrediction prediction) async {
    setState(() {
      _predictions = [];
      _isSearching = true;
      _errorMessage = null;
    });

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json',
    ).replace(queryParameters: {
      'place_id': prediction.placeId,
      'fields': 'geometry,formatted_address',
      'key': MapsConfig.googleMapsApiKey,
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(res.body);
      final status = decoded['status']?.toString();
      if (status != 'OK') {
        setState(() {
          _errorMessage = decoded['error_message']?.toString() ??
              'Unable to load place details.';
          _isSearching = false;
        });
        return;
      }

      final result = decoded['result'];
      final geometry = result is Map ? result['geometry'] : null;
      final location = geometry is Map ? geometry['location'] : null;
      final lat = location is Map ? location['lat'] : null;
      final lng = location is Map ? location['lng'] : null;
      if (lat is! num || lng is! num) {
        setState(() {
          _errorMessage = 'Unable to locate this address.';
          _isSearching = false;
        });
        return;
      }

      final position = LatLng(lat.toDouble(), lng.toDouble());
      final address = result is Map && result['formatted_address'] != null
          ? result['formatted_address'].toString()
          : prediction.description;

      _searchController.text = address;
      _suppressSearch = true;
      _searchFocusNode.unfocus();
      await _animateCamera(position);
      _updateSelectedPosition(position);
      setState(() {
        _selectedAddress = address;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to load place details.';
        _isSearching = false;
      });
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() {
      _isGeocoding = true;
      _errorMessage = null;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      if (placemarks.isEmpty) {
        setState(() {
          _selectedAddress = _formatCoordinates(position);
          _isGeocoding = false;
        });
        return;
      }

      final place = placemarks.first;
      final parts = <String>[
        if (place.name != null && place.name!.isNotEmpty) place.name!,
        if (place.street != null && place.street!.isNotEmpty) place.street!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea!,
        if (place.country != null && place.country!.isNotEmpty)
          place.country!,
      ];

      setState(() {
        _selectedAddress = parts.isNotEmpty
            ? parts.join(', ')
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

  @override
  Widget build(BuildContext context) {
    final infoText = _isGeocoding ? 'Finding address...' : _selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text('Use'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            onTap: _updateSelectedPosition,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedPosition,
              ),
            },
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search address',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _predictions = [];
                                });
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const LinearProgressIndicator(minHeight: 2),
                  if (_predictions.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _predictions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _predictions[index];
                          return ListTile(
                            dense: true,
                            title: Text(item.description),
                            onTap: () => _selectPrediction(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 86,
            child: FloatingActionButton(
              heroTag: 'current-location',
              onPressed: _isLocating ? null : _moveToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F6BFF),
              child: _isLocating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                  const Text(
                    'Delivery Location',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    infoText,
                    style: const TextStyle(color: Color(0xFF4B5563)),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage ?? '',
                      style: const TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacePrediction {
  const _PlacePrediction({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;

  factory _PlacePrediction.fromJson(Map<String, dynamic> json) {
    return _PlacePrediction(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
