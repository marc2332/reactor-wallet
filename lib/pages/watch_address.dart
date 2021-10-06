import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:solana/solana.dart';
import '../state/store.dart';
import 'package:bip39/bip39.dart' as bip39;

/*
 * Getting Started Page
 */
class WatchAddress extends StatefulWidget {
  WatchAddress({Key? key, required this.store}) : super(key: key);

  Store<AppState> store;

  @override
  WatchAddressState createState() => WatchAddressState(this.store);
}

class WatchAddressState extends State<WatchAddress> {
  Store<AppState> store;
  late String address;

  WatchAddressState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watch an address')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Empty address';
                        } else if (value.length < 44) {
                          return 'Address is too short';
                        } else if (value.length > 44) {
                          return 'Adress is too long';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your address',
                      ),
                      onChanged: (String value) async {
                        address = value;
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                child: Text("Continue"),
                onPressed: addAccount,
              )
            ],
          )
        ],
      ),
    );
  }

  void addAccount() async {
    // Create the account
    ClientAccount account = new ClientAccount(
        address,
        0,
        store.state.generateAccountName(),
        "https://api.mainnet-beta.solana.com");

    // Add the account
    store.state.addAccount(account);

    // Refresh the balances
    store.state.loadSolValue().then((_) {
      // Trigger the rendering
      store.dispatch({"type": StateActions.SolValueRefreshed});

      // Go to Home page
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
