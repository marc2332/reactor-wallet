import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/pages/create_wallet.dart';
import 'package:reactor_wallet/pages/import_wallet.dart';
import 'package:reactor_wallet/pages/manage_accounts.dart';
import 'package:reactor_wallet/pages/watch_address.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/theme.dart';
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
    final license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['fonts'], license);
  });

  await Executor().warmUp();

  runApp(ProviderScope(child: App()));
}

class App extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TokenTrackers tokensTracer = ref.read(tokensTrackerProvider);
    ref.watch(settingsProvider);
    ThemeType selectedTheme = ref.read(settingsProvider.notifier).getTheme();
    bool isDarkTheme = selectedTheme == ThemeType.dark;

    useEffect(() {
      loadState(tokensTracer, ref);
    }, []);

    return MaterialApp(
      title: 'Reactor Wallet',
      theme: lighTheme,
      darkTheme: darkTheme,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomePage(),
        '/account_selection': (_) => const AccountSelectionPage(),
        '/watch_address': (_) => const WatchAddress(),
        '/create_wallet': (_) => const CreateWallet(),
        '/import_wallet': (_) => const ImportWallet(),
        '/manage_accounts': (_) => const ManageAccountsPage(),
      },
    );
  }
}
