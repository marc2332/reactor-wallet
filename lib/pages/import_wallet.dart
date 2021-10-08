import 'package:flutter/material.dart';
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
  final store;
  late String mnemonic;

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
    store.importWallet(mnemonic).then((_) {
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
