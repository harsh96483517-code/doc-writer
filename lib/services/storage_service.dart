import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/doc.dart';

/// Stores each document as a small JSON file in the app's documents directory.
class StorageService {
  static const String _folder = 'doc_writer_docs';

  Future<Directory> _docsDir() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${base.path}/$_folder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<Doc>> loadAll() async {
    try {
      final Directory dir = await _docsDir();
      final List<File> files = dir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.json'))
          .toList();
      final List<Doc> docs = <Doc>[];
      for (final File file in files) {
        try {
          docs.add(Doc.fromJsonString(await file.readAsString()));
        } catch (_) {
          // Skip a corrupt file rather than failing the whole list.
        }
      }
      docs.sort((Doc a, Doc b) => b.updatedAt.compareTo(a.updatedAt));
      return docs;
    } catch (_) {
      return <Doc>[];
    }
  }

  Future<void> save(Doc doc) async {
    final Directory dir = await _docsDir();
    final File file = File('${dir.path}/${doc.id}.json');
    await file.writeAsString(doc.toJsonString());
  }

  Future<void> delete(Doc doc) async {
    final Directory dir = await _docsDir();
    final File file = File('${dir.path}/${doc.id}.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
