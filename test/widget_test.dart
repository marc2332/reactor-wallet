import 'package:flutter_test/flutter_test.dart';
import 'package:reactor_wallet/main.dart';

void main() {
  testWidgets('app', (WidgetTester tester) async {
    await tester.pumpWidget(App());
  });
}
