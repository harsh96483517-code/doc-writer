import 'package:flutter/material.dart';

import '../models/doc.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    this.doc,
    this.template = DocTemplate.plain,
  });

  final Doc? doc;

  /// Used only when creating a brand-new document ([doc] is null).
  final DocTemplate template;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final StorageService _storage = StorageService();
  final PdfService _pdf = PdfService();
  late Doc _doc;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();

  // Letter-only fields.
  final TextEditingController _senderName = TextEditingController();
  final TextEditingController _senderAddress = TextEditingController();
  final TextEditingController _recipientName = TextEditingController();
  final TextEditingController _recipientAddress = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _salutation = TextEditingController();
  final TextEditingController _closing = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bool newLetter = widget.doc == null && widget.template == DocTemplate.letter;
    _doc = widget.doc ??
        Doc(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          template: widget.template,
          salutation: newLetter ? 'Dear Sir/Madam,' : '',
          closing: newLetter ? 'Yours sincerely,' : '',
          updatedAt: DateTime.now(),
        );

    _title.text = _doc.title;
    _body.text = _doc.body;
    _senderName.text = _doc.senderName;
    _senderAddress.text = _doc.senderAddress;
    _recipientName.text = _doc.recipientName;
    _recipientAddress.text = _doc.recipientAddress;
    _subject.text = _doc.subject;
    _salutation.text = _doc.salutation;
    _closing.text = _doc.closing;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _senderName.dispose();
    _senderAddress.dispose();
    _recipientName.dispose();
    _recipientAddress.dispose();
    _subject.dispose();
    _salutation.dispose();
    _closing.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    _doc
      ..title = _title.text
      ..body = _body.text
      ..senderName = _senderName.text
      ..senderAddress = _senderAddress.text
      ..recipientName = _recipientName.text
      ..recipientAddress = _recipientAddress.text
      ..subject = _subject.text
      ..salutation = _salutation.text
      ..closing = _closing.text
      ..updatedAt = DateTime.now();
    await _storage.save(_doc);
  }

  Future<void> _save() async {
    await _persist();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Future<void> _print() async {
    await _persist();
    await _pdf.printDoc(_doc);
  }

  Future<void> _share() async {
    await _persist();
    await _pdf.shareDoc(_doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_doc.displayTitle),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save_outlined),
            onPressed: _save,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'print') _print();
              if (value == 'share') _share();
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'print', child: Text('Print')),
              PopupMenuItem<String>(
                value: 'share',
                child: Text('Save / Share PDF'),
              ),
            ],
          ),
        ],
      ),
      body: _doc.isLetter ? _buildLetterForm() : _buildPlainForm(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _print,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Save / Share PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlainForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _body,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: 'Write your document...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _field(_senderName, 'Your name'),
        _field(_senderAddress, 'Your address', lines: 2),
        _field(_recipientName, 'Recipient name'),
        _field(_recipientAddress, 'Recipient address', lines: 2),
        _field(_subject, 'Subject'),
        _field(_salutation, 'Salutation', hint: 'Dear Sir/Madam,'),
        _field(_body, 'Letter body', lines: 8),
        _field(_closing, 'Closing', hint: 'Yours sincerely,'),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines == 1 ? 1 : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: lines > 1,
        ),
      ),
    );
  }
}
