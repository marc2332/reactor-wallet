import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/pages/getting_started.dart';
import 'state/store.dart' show AppState, createStore;
import 'pages/home.dart';
import 'package:redux/redux.dart';

main() async {
  var store = await createStore();
  runApp(App(store));
}

class App extends StatelessWidget {
  final Store<AppState> store;
  late String initialRoute = "/home";

  App(this.store) {
    /*
     * If there isn't any account created yet, then launch Getting Started Page
     */
    if (store.state.currentAccountName == "") {
      this.initialRoute = "/getting_started";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: this.store,
      child: MaterialApp(
        title: 'solana wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: this.initialRoute,
        routes: {
          '/home': (context) => HomePage(
                store: this.store,
              ),
          '/getting_started': (context) =>
              GettingStartedPage(store: this.store),
        },
      ),
    );
  }
}
