class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      final content = json['content'];
      print('🔍 Parsing PaginatedResponse, content type: ${content.runtimeType}');

      if (content == null) {
        print('⚠️ Content is null, returning empty list');
        return PaginatedResponse(
          content: [],
          totalPages: 0,
          totalElements: 0,
          size: 0,
          number: 0,
          first: true,
          last: true,
          empty: true,
        );
      }

      if (content is! List) {
        print('❌ Content is not a List, it is: ${content.runtimeType}');
        print('❌ Content value: $content');
        throw Exception('Expected List for content, got ${content.runtimeType}');
      }

      return PaginatedResponse(
        content: content
            .map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList(),
        totalPages: json['totalPages'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        size: json['size'] ?? 0,
        number: json['number'] ?? 0,
        first: json['first'] ?? true,
        last: json['last'] ?? true,
        empty: json['empty'] ?? true,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing PaginatedResponse: $e');
      print('❌ JSON: $json');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  PaginatedResponse<T> copyWith({
    List<T>? content,
    int? totalPages,
    int? totalElements,
    int? size,
    int? number,
    bool? first,
    bool? last,
    bool? empty,
  }) {
    return PaginatedResponse<T>(
      content: content ?? this.content,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      size: size ?? this.size,
      number: number ?? this.number,
      first: first ?? this.first,
      last: last ?? this.last,
      empty: empty ?? this.empty,
    );
  }

  bool get hasNextPage => !last;
}
