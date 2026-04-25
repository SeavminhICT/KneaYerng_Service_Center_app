class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine,
    required this.note,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String addressLine;
  final String note;
  final double lat;
  final double lng;
  final DateTime createdAt;

  factory SavedAddress.fromMap(Map<String, dynamic> map) {
    return SavedAddress(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Location',
      phone: map['phone']?.toString() ?? '',
      addressLine: map['address_line']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      lat: _toDouble(map['lat']) ?? 0,
      lng: _toDouble(map['lng']) ?? 0,
      createdAt: _toDate(map['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address_line': addressLine,
      'note': note,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final raw = value.toString();
  if (raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}

double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
