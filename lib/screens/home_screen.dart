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

  Future<void> _openEditor([Doc? doc]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditorScreen(doc: doc)),
    );
    _load();
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
                    final String preview =
                        doc.body.trim().replaceAll('\n', ' ');
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(doc.displayTitle),
                      subtitle: Text(
                        preview.isEmpty ? 'Empty document' : preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openEditor(doc),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(doc),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.edit),
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
          'No documents yet.\nTap "New" to write one.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
