import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'state/store.dart'
    show AppState, StateActions, WalletAccount, createStore;
import 'pages/home.dart';

main() {
  runApp(App());
}

class App extends StatelessWidget {
  final store = createStore();

  App() {
    var mainAccount = new WalletAccount("adress_here", 0, "Main");

    store.state.currentAccountName = mainAccount.name;

    store.dispatch({"type": StateActions.AddAccount, "account": mainAccount});

    mainAccount.getBalance().then(
          (mainAccountBalance) => {
            store.dispatch({
              "type": StateActions.SetBalance,
              "name": mainAccount.name,
              "balance": mainAccountBalance
            }),
          },
        );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      // Pass the store to the StoreProvider. Any ancestor `StoreConnector`
      // Widgets will find and use this value as the `Store`.
      store: this.store,
      child: MaterialApp(
        title: 'solana wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(store: store),
      ),
    );
  }
}
