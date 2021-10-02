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
          return store.state.getCurrentAccount().name;
        }, builder: (context, balance) {
          return Text('Account: $balance');
        }),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StoreConnector<AppState, String>(converter: (store) {
              var balance = store.state.getCurrentAccount().balance.toString();
              if (balance.length >= 5) {
                return balance.substring(0, 5);
              } else {
                return balance;
              }
            }, builder: (context, balance) {
              return Text(balance, style: TextStyle(fontSize: 40));
            }),
            Text(
              ' SOL',
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
