import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../state/store.dart';

/*
 * Home Page
 */
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
        title: StoreConnector<AppState, String>(converter: (store) {
          WalletAccount? account = store.state.getCurrentAccount();
          if (account == null) {
            return "Not selected";
          } else {
            return account.name;
          }
        }, builder: (context, balance) {
          return Text('Account: $balance');
        }),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StoreConnector<AppState, String>(converter: (store) {
                  WalletAccount? account = store.state.getCurrentAccount();
                  if (account == null) {
                    return "0";
                  } else {
                    String balance = account.balance.toString();
                    if (balance.length >= 5) {
                      return balance.substring(0, 5);
                    } else {
                      return balance;
                    }
                  }
                }, builder: (context, balance) {
                  return Text(balance, style: TextStyle(fontSize: 50));
                }),
                Text(' SOL'),
              ],
            ),
            MaterialButton(
              child: Text("Log off"),
              onPressed: logOff,
            ),
          ],
        ),
      ),
    );
  }

  void logOff() {
    Navigator.pushReplacementNamed(context, "/getting_started");

    store.dispatch({
      "type": StateActions.RemoveAccount,
      "name": store.state.currentAccountName
    });
  }
}
