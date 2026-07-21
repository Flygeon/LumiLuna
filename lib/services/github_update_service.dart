import 'dart:convert';
import 'dart:io';

import '../core/constants/app_constants.dart';

class GithubRelease {
  final String version;
  final String name;
  final String body;
  final String url;
  final DateTime? publishedAt;

  const GithubRelease({
    required this.version,
    required this.name,
    required this.body,
    required this.url,
    this.publishedAt,
  });

  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String? ?? '').replaceFirst('v', '');
    return GithubRelease(
      version: tag,
      name: json['name'] as String? ?? tag,
      body: json['body'] as String? ?? '',
      url: json['html_url'] as String? ??
          'https://github.com/${AppConstants.githubRepository}/releases',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  }
}

class GithubUpdateService {
  GithubUpdateService._();

  static Future<GithubRelease?> checkForUpdate(String currentVersion) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.https(
        'api.github.com',
        '/repos/${AppConstants.githubRepository}/releases/latest',
      ));
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'LumiLuna');
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != HttpStatus.ok) return null;
      final json = jsonDecode(await response.transform(utf8.decoder).join());
      if (json is! Map<String, dynamic>) return null;
      final release = GithubRelease.fromJson(json);
      return _compareVersions(release.version, currentVersion) > 0 ? release : null;
    } finally {
      client.close(force: true);
    }
  }

  static int _compareVersions(String left, String right) {
    List<int> parts(String value) => RegExp(r'\d+')
        .allMatches(value)
        .map((match) => int.tryParse(match.group(0)!) ?? 0)
        .toList();
    final a = parts(left);
    final b = parts(right);
    for (var i = 0; i < (a.length > b.length ? a.length : b.length); i++) {
      final diff = (i < a.length ? a[i] : 0) - (i < b.length ? b[i] : 0);
      if (diff != 0) return diff.sign;
    }
    return 0;
  }
}
