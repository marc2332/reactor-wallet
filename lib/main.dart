import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/insufficient_funds.dart';
import 'package:reactor_wallet/dialogs/select_account.dart';
import 'package:reactor_wallet/dialogs/make_transaction_manually.dart';
import 'package:reactor_wallet/pages/setup_password.dart';
import 'package:reactor_wallet/pages/create_wallet.dart';
import 'package:reactor_wallet/pages/import_wallet.dart';
import 'package:reactor_wallet/pages/manage_accounts.dart';
import 'package:reactor_wallet/pages/splashscreen.dart';
import 'package:reactor_wallet/pages/watch_address.dart';
import 'package:reactor_wallet/pages/welcome.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/solana_pay.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:uni_links/uni_links.dart';
import 'package:worker_manager/worker_manager.dart';
import 'pages/home.dart';
import 'pages/account_selection.dart';
import 'package:desktop_window/desktop_window.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(const Size(400, 400));
  }

  LicenseRegistry.addLicense(() async* {
    final latoLicense = await rootBundle.loadString('fonts/Lato_OFL.txt');
    yield LicenseEntryWithLineBreaks(['fonts'], latoLicense);
    final poppinsLicense = await rootBundle.loadString('fonts/Poppins_OFL.txt');
    yield LicenseEntryWithLineBreaks(['fonts'], poppinsLicense);
  });

  await Executor().warmUp();

  runApp(const ProviderScope(child: App()));
}

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    ThemeType selectedTheme = ref.read(settingsProvider.notifier).getTheme();
    bool isDarkTheme = selectedTheme == ThemeType.dark;

    return MaterialApp(
      title: 'Reactor Wallet',
      theme: lighTheme,
      darkTheme: darkTheme,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splashscreen',
      routes: {
        '/splashscreen': (_) => const SplashScreen(),
        '/home': (_) => const LinkListenerWrapper(child: HomePage()),
        '/account_selection': (_) => const LinkListenerWrapper(child: AccountSelectionPage()),
        '/welcome': (_) => const WelcomePage(),
        '/watch_address': (_) => const LinkListenerWrapper(child: WatchAddress()),
        '/create_wallet': (_) => const LinkListenerWrapper(child: CreateWallet()),
        '/import_wallet': (_) => const LinkListenerWrapper(child: ImportWallet()),
        '/manage_accounts': (_) => const LinkListenerWrapper(child: ManageAccountsPage()),
      },
    );
  }
}

class LinkListenerWrapper extends HookConsumerWidget {
  final Widget child;

  const LinkListenerWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          return () => {};
        }
        try {
          final listener = uriLinkStream.listen(
            (Uri? uri) {
              if (uri != null) {
                final transaction = TransactionSolanaPay.parseUri(uri.toString());

                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) async {
                    final account = await selectAccount(context);
                    if (account is WalletAccount) {
                      String defaultTokenSymbol = "SOL";

                      if (transaction.splToken != null) {
                        try {
                          Token selectedToken = account.getTokenByMint(transaction.splToken!);
                          defaultTokenSymbol = selectedToken.info.symbol;
                        } catch (_) {
                          insuficientFundsDialog(context);
                          return;
                        }
                      }

                      makePaymentManuallyDialog(
                        context,
                        account,
                        initialDestination: transaction.recipient,
                        initialSendAmount: transaction.amount ?? 0,
                        defaultTokenSymbol: defaultTokenSymbol,
                      );
                    }
                  },
                );
              }
            },
            onError: (err) {},
          );

          return () => listener.cancel();
        } catch (err) {}
      },
    );

    return child;
  }
}
