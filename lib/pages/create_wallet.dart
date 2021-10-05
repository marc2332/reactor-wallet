import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import '../state/store.dart';
import 'package:bip39/bip39.dart' as bip39;

/*
 * Getting Started Page
 */
class CreateWallet extends StatefulWidget {
  CreateWallet({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  CreateWalletState createState() => CreateWalletState(this.store);
}

class CreateWalletState extends State<CreateWallet> {
  final store;
  late String address;

  CreateWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create wallet')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    // Create the account
    WalletAccount walletAccount = await WalletAccount.generate(
        store.state.generateAccountName(), "https://api.devnet.solana.com");

    // Load the balance
    await walletAccount.refreshBalance();

    // Add the account
    this
        .store
        .dispatch({"type": StateActions.AddAccount, "account": walletAccount});

    // Go to Home page
    Navigator.pushReplacementNamed(context, "/home");
  }
}
