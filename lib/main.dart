import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/pages/create_wallet.dart';
import 'package:solana_wallet/pages/import_wallet.dart';
import 'package:solana_wallet/pages/manage_accounts.dart';
import 'package:solana_wallet/pages/watch_address.dart';
import 'package:worker_manager/worker_manager.dart';
import 'state/store.dart' show AppState, StateWrapper, createStore;
import 'pages/home.dart';
import 'pages/account_selection.dart';

main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['fonts'], license);
  });

  await Executor().warmUp();
  StateWrapper store = await createStore();
  runApp(App(store));
}

class App extends StatelessWidget {
  final StateWrapper store;
  late String initialRoute = '/home';

  App(this.store) {
    /*
     * If there isn't any account created yet, then launch Getting Started Page
     */
    if (store.state.accounts.length == 0) {
      this.initialRoute = '/account_selection';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: this.store,
      child: MaterialApp(
        title: 'Solana wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: this.initialRoute,
        routes: {
          '/home': (context) => HomePage(
                store: this.store,
              ),
          '/account_selection': (context) => AccountSelectionPage(store: this.store),
          '/watch_address': (context) => WatchAddress(store: this.store),
          '/create_wallet': (context) => CreateWallet(store: this.store),
          '/import_wallet': (context) => ImportWallet(store: this.store),
          '/manage_accounts': (context) => ManageAccountsPage(store: this.store),
        },
      ),
    );
  }
}
