class RepairStatusLogEntry {
  final String status;
  final String? note;
  final DateTime? loggedAt;

  const RepairStatusLogEntry({required this.status, this.note, this.loggedAt});

  factory RepairStatusLogEntry.fromJson(Map<String, dynamic> json) {
    return RepairStatusLogEntry(
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      loggedAt: DateTime.tryParse(json['logged_at']?.toString() ?? ''),
    );
  }
}

class RepairQuotationInfo {
  final int id;
  final double partsCost;
  final double laborCost;
  final double totalCost;
  final String status;

  const RepairQuotationInfo({
    required this.id,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.status,
  });

  factory RepairQuotationInfo.fromJson(Map<String, dynamic> json) {
    return RepairQuotationInfo(
      id: _asInt(json['id']),
      partsCost: _asDouble(json['parts_cost']),
      laborCost: _asDouble(json['labor_cost']),
      totalCost: _asDouble(json['total_cost']),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class RepairInvoiceInfo {
  final int id;
  final String invoiceNumber;
  final double total;
  final String paymentStatus;

  const RepairInvoiceInfo({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.paymentStatus,
  });

  factory RepairInvoiceInfo.fromJson(Map<String, dynamic> json) {
    return RepairInvoiceInfo(
      id: _asInt(json['id']),
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      total: _asDouble(json['total']),
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
    );
  }
}

class RepairJob {
  final int id;
  final int? customerId;
  final int? technicianId;
  final String? deviceModel;
  final String? issueType;
  final String serviceType;
  final String status;
  final List<String> allowedNextStatuses;
  final List<String> problems;
  final String? customerName;
  final String? customerPhone;
  final String? technicianName;
  final RepairQuotationInfo? quotation;
  final RepairInvoiceInfo? invoice;
  final List<RepairStatusLogEntry> statusLogs;
  final DateTime? appointmentDatetime;
  final DateTime? createdAt;

  const RepairJob({
    required this.id,
    this.customerId,
    this.technicianId,
    this.deviceModel,
    this.issueType,
    required this.serviceType,
    required this.status,
    this.allowedNextStatuses = const [],
    this.problems = const [],
    this.customerName,
    this.customerPhone,
    this.technicianName,
    this.quotation,
    this.invoice,
    this.statusLogs = const [],
    this.appointmentDatetime,
    this.createdAt,
  });

  String get statusLabel =>
      status.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

  factory RepairJob.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map
        ? Map<String, dynamic>.from(json['customer'] as Map)
        : null;
    final technician = json['technician'] is Map
        ? Map<String, dynamic>.from(json['technician'] as Map)
        : null;
    final quotationJson = json['quotation'];
    final invoiceJson = json['invoice'];
    final problemsRaw = json['problems'];

    return RepairJob(
      id: _asInt(json['id']),
      customerId: json['customer_id'] == null ? null : _asInt(json['customer_id']),
      technicianId: json['technician_id'] == null ? null : _asInt(json['technician_id']),
      deviceModel: json['device_model']?.toString(),
      issueType: json['issue_type']?.toString(),
      serviceType: json['service_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'new',
      allowedNextStatuses: (json['allowed_next_statuses'] is List)
          ? List<String>.from((json['allowed_next_statuses'] as List).map((e) => e.toString()))
          : const [],
      problems: (problemsRaw is List)
          ? problemsRaw
              .whereType<Map>()
              .map((p) => p['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList()
          : const [],
      customerName: customer?['name']?.toString(),
      customerPhone: customer?['phone']?.toString(),
      technicianName: technician?['name']?.toString(),
      quotation: (quotationJson is Map && quotationJson.isNotEmpty)
          ? RepairQuotationInfo.fromJson(Map<String, dynamic>.from(quotationJson))
          : null,
      invoice: (invoiceJson is Map && invoiceJson.isNotEmpty)
          ? RepairInvoiceInfo.fromJson(Map<String, dynamic>.from(invoiceJson))
          : null,
      statusLogs: (json['status_logs'] is List)
          ? (json['status_logs'] as List)
              .whereType<Map>()
              .map((e) => RepairStatusLogEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      appointmentDatetime: DateTime.tryParse(json['appointment_datetime']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
