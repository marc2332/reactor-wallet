import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/main.dart';
import 'package:reactor_wallet/pages/account_selection.dart';
import 'package:reactor_wallet/pages/create_wallet.dart';
import 'package:reactor_wallet/pages/home.dart';
import 'package:reactor_wallet/pages/import_wallet.dart';
import 'package:reactor_wallet/pages/watch_address.dart';
import 'package:reactor_wallet/utils/states.dart';

final appLoadedProviderTesting = StateProvider<bool>((_) {
  return true;
});

void main() {
  group('Navigation', () {
    ProviderScope app = ProviderScope(
      child: App(),
      overrides: [appLoadedProvider.overrideWithProvider(appLoadedProviderTesting)],
    );
    testWidgets('App opens AccountSelectionPage page by default', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      expect(find.byType(HomePage), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(AccountSelectionPage), findsOneWidget);
    });

    testWidgets('WatchAddress page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(WatchAddress), findsOneWidget);
    });

    testWidgets('ImportWallet page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(ImportWallet), findsOneWidget);
    });

    testWidgets('CreateWallet page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).last);
      await tester.pumpAndSettle();

      expect(find.byType(CreateWallet), findsOneWidget);
    });
  });
}
