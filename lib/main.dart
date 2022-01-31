import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/pages/create_wallet.dart';
import 'package:solana_wallet/pages/import_wallet.dart';
import 'package:solana_wallet/pages/manage_accounts.dart';
import 'package:solana_wallet/pages/watch_address.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/tracker.dart';
import 'package:worker_manager/worker_manager.dart';
import 'pages/home.dart';
import 'pages/account_selection.dart';

main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['fonts'], license);
  });

  await Executor().warmUp();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: App()));
}

extension CustomColors on ThemeData {
  Color iconThemeColor() {
    return (this.brightness == Brightness.light) ? Colors.white : Colors.black;
  }

  Color get iconColor => iconThemeColor();
}

class App extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TokenTrackers tokensTracer = ref.read(tokensTrackerProvider);
    ref.watch(settingsProvider);
    ThemeType selectedTheme = ref.read(settingsProvider.notifier).getTheme();
    bool isDarkTheme = selectedTheme == ThemeType.Dark;

    useEffect(() {
      loadState(tokensTracer, ref);
    }, []);

    return MaterialApp(
      title: 'Solana wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        dialogBackgroundColor: Colors.grey[850],
        dialogTheme: DialogTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(backgroundColor: Colors.yellow.shade800),
        cardTheme: CardTheme(
          color: Colors.grey[850],
        ),
        listTileTheme: ListTileThemeData(textColor: Colors.white),
        primarySwatch: Colors.orange,
        dividerColor: Colors.grey[700],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedIconTheme: IconThemeData(color: Colors.yellow.shade800),
          selectedItemColor: Colors.yellow.shade800,
          unselectedIconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.yellow.shade800),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.yellow.shade800),
          trackColor: MaterialStateProperty.all(Colors.yellow.shade900),
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: Colors.white,
          ),
          overline: TextStyle(
            color: Colors.white,
          ),
          button: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (_) => HomePage(),
        '/account_selection': (_) => AccountSelectionPage(),
        '/watch_address': (_) => WatchAddress(),
        '/create_wallet': (_) => CreateWallet(),
        '/import_wallet': (_) => ImportWallet(),
        '/manage_accounts': (_) => ManageAccountsPage(),
      },
    );
  }
}
