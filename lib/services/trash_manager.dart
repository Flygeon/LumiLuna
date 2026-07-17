import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';

/// A record of a file that has been moved to the recycle bin / app trash.
class TrashEntry {
  final String originalPath;
  final DateTime deletedAt;
  final int size;
  final String trashLocation;

  const TrashEntry({
    required this.originalPath,
    required this.deletedAt,
    required this.size,
    required this.trashLocation,
  });

  String get fileName =>
      originalPath.split(Platform.pathSeparator).last;

  String get originalFolder =>
      originalPath.substring(0, originalPath.lastIndexOf(Platform.pathSeparator));

  Map<String, dynamic> toJson() => {
        'originalPath': originalPath,
        'deletedAt': deletedAt.toIso8601String(),
        'size': size,
        'trashLocation': trashLocation,
      };

  factory TrashEntry.fromJson(Map<String, dynamic> json) => TrashEntry(
        originalPath: json['originalPath'] as String,
        deletedAt: DateTime.parse(json['deletedAt'] as String),
        size: json['size'] as int,
        trashLocation: json['trashLocation'] as String,
      );
}

/// Manages the app-internal trash / recycle bin.
///
/// On Windows the primary path is the system Recycle Bin (via PowerShell COM).
/// When that fails (or on non-Windows platforms) files are moved to an
/// app-internal trash directory and tracked in a JSON manifest.
class TrashManager {
  TrashManager._();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Future<Directory> _trashDir() async {
    final dir = await getApplicationSupportDirectory();
    final trash = Directory('${dir.path}${Platform.pathSeparator}${AppConstants.trashDirName}');
    await trash.create(recursive: true);
    return trash;
  }

  static Future<File> _manifestFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}${AppConstants.trashManifestName}');
  }

  static Future<List<TrashEntry>> _readManifest() async {
    final file = await _manifestFile();
    if (!await file.exists()) return [];
    try {
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>().map(TrashEntry.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeManifest(List<TrashEntry> entries) async {
    final file = await _manifestFile();
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Move [item] to the recycle bin / trash.
  ///
  /// Returns a [TrashEntry] on success, or `null` if the operation failed.
  static Future<TrashEntry?> moveToTrash(MediaItem item) async {
    final file = File(item.path);
    if (!await file.exists()) return null;

    // Try Windows Recycle Bin first.
    if (Platform.isWindows) {
      final ok = await _sendToRecycleBinWindows(item.path);
      if (ok) {
        return TrashEntry(
          originalPath: item.path,
          deletedAt: DateTime.now(),
          size: item.size,
          trashLocation: 'recycle_bin', // special marker
        );
      }
    }

    // Fallback: move to app-internal trash directory.
    try {
      final trash = await _trashDir();
      final unique = '${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';
      final ext = item.extension.isNotEmpty ? '.${item.extension}' : '';
      final dest = '${trash.path}${Platform.pathSeparator}$unique$ext';
      // On Android (scoped storage) and some Windows edge cases, File.rename
      // fails across storage volumes / restricted directories.  Fall back to
      // copy + delete so the operation still succeeds.
      try {
        await file.rename(dest);
      } catch (_) {
        await file.copy(dest);
        await file.delete();
      }

      final entry = TrashEntry(
        originalPath: item.path,
        deletedAt: DateTime.now(),
        size: item.size,
        trashLocation: dest,
      );

      final entries = await _readManifest();
      entries.add(entry);
      await _writeManifest(entries);
      return entry;
    } catch (_) {
      return null;
    }
  }

  /// Restore [entry] to its original location.
  static Future<bool> restore(TrashEntry entry) async {
    // If it was sent to the system recycle bin, we can't restore programmatically.
    if (entry.trashLocation == 'recycle_bin') {
      return false;
    }

    try {
      // Ensure the original folder still exists.
      final origDir = Directory(entry.originalFolder);
      if (!await origDir.exists()) {
        await origDir.create(recursive: true);
      }

      final file = File(entry.trashLocation);
      if (!await file.exists()) return false;

      await file.rename(entry.originalPath);

      final entries = await _readManifest();
      entries.removeWhere((e) => e.originalPath == entry.originalPath);
      await _writeManifest(entries);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Permanently delete a trashed file.
  static Future<bool> permanentlyDelete(TrashEntry entry) async {
    if (entry.trashLocation == 'recycle_bin') return false;

    try {
      final file = File(entry.trashLocation);
      if (await file.exists()) await file.delete();

      final entries = await _readManifest();
      entries.removeWhere((e) => e.originalPath == entry.originalPath);
      await _writeManifest(entries);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Permanently delete **all** trashed files.
  static Future<bool> emptyTrash() async {
    final entries = await _readManifest();
    var allOk = true;
    for (final entry in entries) {
      if (entry.trashLocation == 'recycle_bin') continue;
      try {
        final file = File(entry.trashLocation);
        if (await file.exists()) await file.delete();
      } catch (_) {
        allOk = false;
      }
    }
    await _writeManifest([]);
    return allOk;
  }

  /// List all entries currently in the trash.
  static Future<List<TrashEntry>> listTrash() => _readManifest();

  /// Total byte size of all files currently in the trash (excludes recycle bin
  /// entries since we cannot query the real size from the system bin).
  static Future<int> getTrashSize() async {
    final entries = await _readManifest();
    var total = 0;
    for (final e in entries) {
      if (e.trashLocation != 'recycle_bin') {
        total += e.size;
      }
    }
    return total;
  }

  // ---------------------------------------------------------------------------
  // Windows Recycle Bin via PowerShell COM
  // ---------------------------------------------------------------------------

  /// Send a file to the Windows Recycle Bin through the Microsoft.VisualBasic
  /// COM interop. Returns `true` when PowerShell reports success.
  static Future<bool> _sendToRecycleBinWindows(String path) async {
    // Escape single quotes for the PowerShell string.
    final safePath = path.replaceAll("'", "''");
    final script =
        "Add-Type -AssemblyName Microsoft.VisualBasic; "
        "[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('$safePath', 'SendToRecycleBin')";
    try {
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-Command', script],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
