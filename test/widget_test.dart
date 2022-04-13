import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/main.dart';
import 'package:reactor_wallet/pages/create_wallet.dart';
import 'package:reactor_wallet/pages/import_wallet.dart';
import 'package:reactor_wallet/pages/setup_password.dart';
import 'package:reactor_wallet/pages/splashscreen.dart';
import 'package:reactor_wallet/pages/watch_address.dart';
import 'package:reactor_wallet/pages/welcome.dart';
import 'package:reactor_wallet/utils/state/providers.dart';

final appLoadedProviderTesting = StateProvider<bool>((_) {
  return true;
});

void main() {
  group('Startup with no encryption key', () {
    final emptyEncryptionKeyProviderTesting = StateProvider<Uint8List?>((_) {
      return null;
    });

    ProviderScope app = ProviderScope(
      child: const App(),
      overrides: [
        appLoadedProvider.overrideWithProvider(
          appLoadedProviderTesting,
        ),
        encryptionKeyProvider.overrideWithProvider(
          emptyEncryptionKeyProviderTesting,
        ),
      ],
    );

    testWidgets('App opens Welcome page by default', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('PasswordSetup page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(SetupPasswordPage), findsOneWidget);
    });
  });
  group('Startup with encryption', () {
    final encryptionKeyProviderTesting = StateProvider<Uint8List?>((_) {
      return Uint8List.fromList(Hive.generateSecureKey());
    });

    ProviderScope app = ProviderScope(
      child: const App(),
      overrides: [
        appLoadedProvider.overrideWithProvider(
          appLoadedProviderTesting,
        ),
        encryptionKeyProvider.overrideWithProvider(
          encryptionKeyProviderTesting,
        ),
      ],
    );

    testWidgets('App opens Welcome page by default', (WidgetTester tester) async {
      await tester.pumpWidget(app);

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('ImportWallet page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(ImportWallet), findsOneWidget);
    });

    testWidgets('CreateWallet page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(CreateWallet), findsOneWidget);
    });

    testWidgets('WatchAddress page', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).last);
      await tester.pumpAndSettle();

      expect(find.byType(WatchAddress), findsOneWidget);
    });
  });
}
