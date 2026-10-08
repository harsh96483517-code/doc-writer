import 'package:flutter/material.dart';

import '../models/doc.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.doc});

  final Doc? doc;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final StorageService _storage = StorageService();
  final PdfService _pdf = PdfService();
  late Doc _doc;

  @override
  void initState() {
    super.initState();
    _doc = widget.doc ??
        Doc(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: '',
          body: '',
          updatedAt: DateTime.now(),
        );
    _titleController.text = _doc.title;
    _bodyController.text = _doc.body;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    _doc
      ..title = _titleController.text
      ..body = _bodyController.text
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
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
      ),
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
}
