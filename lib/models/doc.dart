import 'dart:convert';

/// The two kinds of document the app can produce.
enum DocTemplate { plain, letter }

DocTemplate docTemplateFromString(String? value) =>
    value == 'letter' ? DocTemplate.letter : DocTemplate.plain;

/// A single document the user has written — either a plain note or a letter.
class Doc {
  Doc({
    required this.id,
    this.template = DocTemplate.plain,
    this.title = '',
    this.body = '',
    this.senderName = '',
    this.senderAddress = '',
    this.recipientName = '',
    this.recipientAddress = '',
    this.subject = '',
    this.salutation = '',
    this.closing = '',
    required this.updatedAt,
  });

  final String id;
  DocTemplate template;

  // Plain-note fields.
  String title;
  String body;

  // Letter-only fields.
  String senderName;
  String senderAddress;
  String recipientName;
  String recipientAddress;
  String subject;
  String salutation;
  String closing;

  DateTime updatedAt;

  bool get isLetter => template == DocTemplate.letter;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'template': template.name,
        'title': title,
        'body': body,
        'senderName': senderName,
        'senderAddress': senderAddress,
        'recipientName': recipientName,
        'recipientAddress': recipientAddress,
        'subject': subject,
        'salutation': salutation,
        'closing': closing,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        id: json['id'] as String,
        template: docTemplateFromString(json['template'] as String?),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        senderAddress: json['senderAddress'] as String? ?? '',
        recipientName: json['recipientName'] as String? ?? '',
        recipientAddress: json['recipientAddress'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        salutation: json['salutation'] as String? ?? '',
        closing: json['closing'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static Doc fromJsonString(String source) =>
      Doc.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  /// A sensible display title for the list and the app bar, never empty.
  String get displayTitle {
    if (isLetter) {
      if (subject.trim().isNotEmpty) return subject.trim();
      if (recipientName.trim().isNotEmpty) return 'Letter to ${recipientName.trim()}';
      return 'Untitled letter';
    }
    return title.trim().isEmpty ? 'Untitled' : title.trim();
  }
}
