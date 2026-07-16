import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Provides the singletons [DatabaseService] instance.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  // DatabaseService is all-static; this provider exists so other providers
  // can depend on it for explicit ordering / override in tests.
  return DatabaseService();
});
