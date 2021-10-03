import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../state/store.dart';

/*
 * Getting Started Page
 */
class GettingStartedPage extends StatefulWidget {
  GettingStartedPage({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  GettingStartedPageState createState() => GettingStartedPageState(this.store);
}

class GettingStartedPageState extends State<GettingStartedPage> {
  final store;

  GettingStartedPageState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Getting started')
      ),
      body: Column(children: [
        Text("Write your address:"),
        Form(
          autovalidateMode: AutovalidateMode.always,
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(200, 50)),
            child: TextFormField(
              onFieldSubmitted: (String value) {
                print(value);
                this.store.dispatch({
                  "type": StateActions.AddAccount,
                  "account": new WalletAccount(
                    value,
                    0,
                    "Main",
                    "https://api.mainnet-beta.solana.com"
                  )
                });
              },
            ),
          )
        )
      ],)
    );
  }
}
