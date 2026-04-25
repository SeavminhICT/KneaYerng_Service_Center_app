class SearchSuggestion {
  const SearchSuggestion({
    required this.type,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String type;
  final String label;
  final String value;
  final String? subtitle;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      type: (json['type'] ?? 'keyword').toString(),
      label: (json['label'] ?? json['value'] ?? '').toString(),
      value: (json['value'] ?? json['label'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}
