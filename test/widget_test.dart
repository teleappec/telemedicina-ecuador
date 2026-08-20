// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('Carga inicial de la aplicación', (WidgetTester tester) async {
    await tester.pumpWidget(const TelemedicinaApp());
  });
}
