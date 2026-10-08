import 'dart:convert';

/// A single document the user has written.
class Doc {
  Doc({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String id;
  String title;
  String body;
  DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static Doc fromJsonString(String source) =>
      Doc.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  /// A sensible display title, never empty.
  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();
}
