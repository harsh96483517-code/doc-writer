import 'package:doc_writer/models/doc.dart';
import 'package:doc_writer/services/pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  bool looksLikePdf(List<int> bytes) =>
      bytes.length > 1000 && String.fromCharCodes(bytes.take(5)) == '%PDF-';

  test('builds a PDF for a letter with Hindi text in bold and regular', () async {
    final Doc letter = Doc(
      id: '1',
      template: DocTemplate.letter,
      senderName: 'हर्ष कुमार',
      senderAddress: 'Delhi',
      date: '9 October 2026',
      recipientName: 'The Principal',
      subject: 'छुट्टी के लिए प्रार्थना पत्र',
      salutation: 'Dear Sir/Madam,',
      body: 'Hello\nनमस्ते, मुझे दो दिन की छुट्टी चाहिए।',
      closing: 'Yours sincerely,',
      updatedAt: DateTime(2026, 10, 9),
    );
    expect(looksLikePdf(await PdfService().buildPdf(letter)), isTrue);
  });

  test('builds a PDF for a plain document', () async {
    final Doc doc = Doc(
      id: '2',
      title: 'Notes',
      body: 'English and हिन्दी together.',
      updatedAt: DateTime(2026, 10, 9),
    );
    expect(looksLikePdf(await PdfService().buildPdf(doc)), isTrue);
  });
}
