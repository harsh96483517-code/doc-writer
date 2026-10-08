import 'package:flutter/material.dart';

import '../models/doc.dart';
import '../services/storage_service.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Doc> _docs = <Doc>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<Doc> docs = await _storage.loadAll();
    if (!mounted) return;
    setState(() {
      _docs = docs;
      _loading = false;
    });
  }

  Future<void> _openEditor([Doc? doc, DocTemplate template = DocTemplate.plain]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditorScreen(doc: doc, template: template),
      ),
    );
    _load();
  }

  Future<void> _newDocument() async {
    final DocTemplate? choice = await showModalBottomSheet<DocTemplate>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Blank document'),
              onTap: () => Navigator.pop(ctx, DocTemplate.plain),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Letter'),
              onTap: () => Navigator.pop(ctx, DocTemplate.letter),
            ),
          ],
        ),
      ),
    );
    if (choice != null) {
      await _openEditor(null, choice);
    }
  }

  Future<void> _confirmDelete(Doc doc) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('"${doc.displayTitle}" will be removed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await _storage.delete(doc);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DocWriter')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _docs.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  itemCount: _docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int i) {
                    final Doc doc = _docs[i];
                    final String preview = doc.body.trim().replaceAll('\n', ' ');
                    return ListTile(
                      leading: Icon(
                        doc.isLetter ? Icons.mail_outline : Icons.description_outlined,
                      ),
                      title: Text(doc.displayTitle),
                      subtitle: Text(
                        preview.isEmpty ? 'Empty' : preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openEditor(doc, doc.template),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(doc),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newDocument,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No documents yet.\nTap "New" to write a document or a letter.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
