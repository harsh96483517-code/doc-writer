import 'package:flutter_test/flutter_test.dart';

import 'package:doc_writer/main.dart';

void main() {
  testWidgets('Home screen shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const DocWriterApp());
    await tester.pump();
    expect(find.text('DocWriter'), findsWidgets);
  });
}
