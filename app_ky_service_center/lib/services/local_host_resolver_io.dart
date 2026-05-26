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

    final hosts =
        interfaces
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

Future<List<String>> guessLanApiBaseUrls({
  int port = 8000,
  String apiPath = 'api',
}) async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    final localHosts =
        interfaces
            .expand((interface) => interface.addresses)
            .map((address) => address.address)
            .where(_isPrivateLanHost)
            .toList()
          ..sort(_compareHosts);
    if (localHosts.isEmpty) {
      return const [];
    }

    final guessedHosts = <String>{};
    for (final localHost in localHosts) {
      final parts = localHost.split('.');
      if (parts.length != 4) {
        continue;
      }

      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);
      final ownSuffix = int.tryParse(parts[3]);
      if (first == null ||
          second == null ||
          third == null ||
          ownSuffix == null) {
        continue;
      }

      final orderedSuffixes = <int>[];
      for (var delta = 1; delta <= 24; delta++) {
        orderedSuffixes.add(ownSuffix - delta);
        orderedSuffixes.add(ownSuffix + delta);
      }
      orderedSuffixes.addAll(const [
        1,
        2,
        3,
        4,
        5,
        8,
        10,
        20,
        30,
        40,
        50,
        60,
        70,
        80,
        90,
        98,
        99,
        100,
        101,
        110,
        120,
        130,
        140,
        150,
        160,
        170,
        180,
        190,
        200,
        210,
        220,
        230,
        240,
        250,
      ]);

      for (final suffix in orderedSuffixes) {
        if (suffix <= 0 || suffix >= 255 || suffix == ownSuffix) {
          continue;
        }
        guessedHosts.add('$first.$second.$third.$suffix');
      }
    }

    return guessedHosts
        .map(
          (host) => Uri(
            scheme: 'http',
            host: host,
            port: port,
            path: apiPath,
          ).toString().replaceFirst(RegExp(r'/$'), ''),
        )
        .toList(growable: false);
  } catch (_) {
    return const [];
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
