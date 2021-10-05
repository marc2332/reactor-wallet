import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import '../state/store.dart';
import 'package:bip39/bip39.dart' as bip39;

/*
 * Getting Started Page
 */
class ImportWallet extends StatefulWidget {
  ImportWallet({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  ImportWalletState createState() => ImportWalletState(this.store);
}

class ImportWalletState extends State<ImportWallet> {
  final store;
  late String mnemonic;

  ImportWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import wallet')),
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
                          return 'Empty mnemonic';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your mnemonic',
                      ),
                      onChanged: (String value) async {
                        mnemonic = value;
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
                child: Text("Import Wallet"),
                onPressed: importWallet,
              )
            ],
          )
        ],
      ),
    );
  }

  void importWallet() async {
    // Create the account
    WalletAccount walletAccount = new WalletAccount(
        0,
        store.state.generateAccountName(),
        "https://api.devnet.solana.com",
        mnemonic);

    // Create key pair
    await walletAccount.loadKeyPair();

    // Load the balance
    await walletAccount.refreshBalance();

    // Add the account
    this
        .store
        .dispatch({"type": StateActions.AddAccount, "account": walletAccount});

    // Go to Home page
    Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
  }
}
