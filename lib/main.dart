import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/pages/create_wallet.dart';
import 'package:solana_wallet/pages/import_wallet.dart';
import 'package:solana_wallet/pages/manage_accounts.dart';
import 'package:solana_wallet/pages/watch_address.dart';
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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solana wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
