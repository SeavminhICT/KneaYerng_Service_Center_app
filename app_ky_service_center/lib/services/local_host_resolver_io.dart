import 'dart:io';

Future<String?> detectLocalServerBaseUrl({
  int port = 8000,
  String apiPath = 'api',
}) async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    final hosts = interfaces
        .expand((interface) => interface.addresses)
        .map((address) => address.address)
        .where(_isPrivateLanHost)
        .toList()
      ..sort(_compareHosts);

    if (hosts.isEmpty) {
      return null;
    }

    return Uri(
      scheme: 'http',
      host: hosts.first,
      port: port,
      path: apiPath,
    ).toString().replaceFirst(RegExp(r'/$'), '');
  } catch (_) {
    return null;
  }
}

bool _isPrivateLanHost(String host) {
  final parts = host.split('.');
  if (parts.length != 4) {
    return false;
  }

  final octets = parts.map(int.tryParse).toList();
  if (octets.any((octet) => octet == null)) {
    return false;
  }

  final first = octets[0]!;
  final second = octets[1]!;

  if (first == 10) return true;
  if (first == 172 && second >= 16 && second <= 31) return true;
  if (first == 192 && second == 168) return true;
  return false;
}

int _compareHosts(String left, String right) {
  final leftScore = _hostScore(left);
  final rightScore = _hostScore(right);
  if (leftScore != rightScore) {
    return rightScore.compareTo(leftScore);
  }
  return left.compareTo(right);
}

int _hostScore(String host) {
  if (host.startsWith('192.168.')) return 3;
  if (host.startsWith('10.')) return 2;
  if (host.startsWith('172.')) return 1;
  return 0;
}
