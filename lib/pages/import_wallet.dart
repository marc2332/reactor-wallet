import 'package:flutter/material.dart';
import 'package:solana_wallet/components/network_selector.dart';
import '../state/store.dart';

/*
 * Getting Started Page
 */
class ImportWallet extends StatefulWidget {
  ImportWallet({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  ImportWalletState createState() => ImportWalletState(this.store);
}

class ImportWalletState extends State<ImportWallet> {
  final StateWrapper store;
  late String mnemonic;
  late String networkURL;

  ImportWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import wallet')),
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
                      child: Column(
                        children: [
                          TextFormField(
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
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 5),
                            child: NetworkSelector(
                              (String url) {
                                networkURL = url;
                              },
                            ),
                          )
                        ],
                      )),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Import Wallet"),
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
    store.importWallet(mnemonic, networkURL).then((_) {
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
