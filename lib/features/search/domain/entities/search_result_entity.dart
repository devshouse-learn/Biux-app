/// Entidad de resultado de búsqueda global.
class SearchResult {
  final String id;
  final String name;
  final String? photoUrl;
  final String? subtitle;
  final SearchResultType type;

  const SearchResult({
    required this.id,
    required this.name,
    this.photoUrl,
    this.subtitle,
    required this.type,
  });
}

enum SearchResultType { user, group, ride }
