/// Represents a branch configuration with its API endpoint.
///
/// Each branch maps to a separate server instance that shares the same
/// backend system but operates under a different base URL.
class BranchModel {
  final int id;
  final String name;
  final String baseUrl;

  const BranchModel({
    required this.id,
    required this.name,
    required this.baseUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BranchModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
