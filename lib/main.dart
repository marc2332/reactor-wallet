import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/pages/create_wallet.dart';
import 'package:solana_wallet/pages/import_wallet.dart';
import 'package:solana_wallet/pages/watch_address.dart';
import 'state/store.dart' show AppState, createStore;
import 'pages/home.dart';
import 'pages/account_selection.dart';
import 'package:redux/redux.dart';

main() async {
  var store = await createStore();
  runApp(App(store));
}

class App extends StatelessWidget {
  final Store<AppState> store;
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
          '/account_selection': (context) =>
              AccountSelectionPage(store: this.store),
          '/watch_address': (context) => WatchAddress(store: this.store),
          '/create_wallet': (context) => CreateWallet(store: this.store),
          '/import_wallet': (context) => ImportWallet(store: this.store),
        },
      ),
    );
  }
}
