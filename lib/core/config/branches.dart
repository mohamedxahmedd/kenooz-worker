import 'package:kenooz_worker_app/core/config/branch_model.dart';

/// Single source of truth for all branch configurations.
///
/// **No base URL should be hardcoded anywhere else in the project.**
/// Every network layer component resolves its URL through [Branches].
class Branches {
  Branches._();

  static const kenooz = BranchModel(
    id: 1,
    name: 'Kenooz',
    baseUrl: 'https://system.kenooz.co/api/',
  );

  static const kenoozRetag = BranchModel(
    id: 2,
    name: 'Kenooz (Retag)',
    baseUrl: 'https://retag.kenooz.co/api/',
  );

  static const List<BranchModel> all = [kenooz, kenoozRetag];

  /// Default branch for first-time users and migration of existing users.
  static const BranchModel defaultBranch = kenooz;

  /// Resolves a branch by its persisted [id].
  /// Falls back to [defaultBranch] when the id is unknown.
  static BranchModel getById(int id) {
    for (final branch in all) {
      if (branch.id == id) return branch;
    }
    return defaultBranch;
  }
}
