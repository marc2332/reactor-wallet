import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:solana/solana.dart';
import '../state/store.dart';
import 'package:bip39/bip39.dart' as bip39;

/*
 * Getting Started Page
 */
class CreateWallet extends StatefulWidget {
  CreateWallet({Key? key, required this.store}) : super(key: key);

  Store<AppState> store;

  @override
  CreateWalletState createState() => CreateWalletState(this.store);
}

class CreateWalletState extends State<CreateWallet> {
  Store<AppState> store;
  late String address;
  late String accoutName;

  CreateWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create wallet')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              child: Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Empty account name';
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter an account name',
                    ),
                    onChanged: (String value) async {
                      accoutName = value;
                    },
                  ),
                ),
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                child: Text("Create Wallet"),
                onPressed: createWallet,
              )
            ],
          )
        ],
      ),
    );
  }

  void createWallet() async {
    if (accoutName.length > 0 &&
        !store.state.accounts.containsKey(accoutName)) {
      // Create the account
      WalletAccount walletAccount = await WalletAccount.generate(
          accoutName, "https://api.devnet.solana.com");

      // Add the account
      store.state.addAccount(walletAccount);

      // Refresh the balances
      store.state.loadSolValue().then((_) {
        // Trigger the rendering
        store.dispatch({"type": StateActions.SolValueRefreshed});

        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    }
  }
}
