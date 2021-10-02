import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'state/store.dart' show AppState, StateActions, WalletAccount, createStore;

main() { 
  runApp(App());
}

class App extends StatelessWidget {

  final store = createStore();
  
  App(){

    var mainAccount = new WalletAccount("address_here", 0, "Main");

    store.state.currentAccountName = mainAccount.name;

    store.dispatch({
      "type": StateActions.AddAccount,
      "account":  mainAccount
    });

    mainAccount.getBalance().then((mainAccountBalance) => {
      store.dispatch({
        "type": StateActions.SetBalance,
        "name": mainAccount.name,
        "balance": mainAccountBalance
      })
    });
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
      )
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  HomePageState createState() => HomePageState(this.store);
}

class HomePageState extends State<HomePage> {

  final store;

  HomePageState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StoreConnector<AppState, String>(
            converter: (store) {
              return store.state.getCurrentAccount().name;
            },
            builder: (context, balance) {
              return Text('Account: $balance');
            }
          ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Balance is:',
            ),
            StoreConnector<AppState, String>(
              converter: (store) {
                 return store.state.getCurrentAccount().balance.toString().substring(0, 5);
              },
              builder: (context, balance) {
                return Text('$balance SOL');
              }
            )
          ],
        ),
      )
    );
  }
}
