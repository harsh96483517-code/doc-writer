import 'package:doc_writer/models/doc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatLetterDate', () {
    test('uses the day, full month name and year', () {
      expect(formatLetterDate(DateTime(2026, 10, 8)), '8 October 2026');
      expect(formatLetterDate(DateTime(2027, 1, 31)), '31 January 2027');
    });
  });

  group('Doc.letterDate', () {
    test('uses the stored date, trimmed', () {
      final Doc doc = Doc(
        id: '1',
        template: DocTemplate.letter,
        date: ' 1 May 2026 ',
        updatedAt: DateTime(2026, 10, 8),
      );
      expect(doc.letterDate, '1 May 2026');
    });

    test('falls back to the last-saved date when none is stored', () {
      final Doc doc = Doc(
        id: '1',
        template: DocTemplate.letter,
        updatedAt: DateTime(2026, 10, 8),
      );
      expect(doc.letterDate, '8 October 2026');
    });

    test('does not change when the document is saved again later', () {
      final Doc doc = Doc(
        id: '1',
        template: DocTemplate.letter,
        date: '8 October 2026',
        updatedAt: DateTime(2026, 10, 8),
      );
      doc.updatedAt = DateTime(2030, 1, 1);
      expect(doc.letterDate, '8 October 2026');
    });
  });

  group('Doc JSON', () {
    test('round-trips the date', () {
      final Doc original = Doc(
        id: '1',
        template: DocTemplate.letter,
        date: '9 October 2026',
        subject: 'Leave request',
        updatedAt: DateTime(2026, 10, 9),
      );
      final Doc copy = Doc.fromJsonString(original.toJsonString());
      expect(copy.date, '9 October 2026');
      expect(copy.letterDate, '9 October 2026');
      expect(copy.subject, 'Leave request');
      expect(copy.isLetter, isTrue);
    });

    test('loads files saved before the date field existed', () {
      final Doc doc = Doc.fromJsonString(
        '{"id":"1","template":"letter","updatedAt":"2026-10-08T10:00:00.000"}',
      );
      expect(doc.date, '');
      expect(doc.letterDate, '8 October 2026');
    });
  });
}
