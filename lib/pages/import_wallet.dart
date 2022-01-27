import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/network_selector.dart';
import 'package:solana_wallet/state/states.dart';

/*
 * Getting Started Page
 */
class ImportWallet extends ConsumerStatefulWidget {
  ImportWallet({Key? key}) : super(key: key);

  @override
  ImportWalletState createState() => ImportWalletState();
}

class ImportWalletState extends ConsumerState<ImportWallet> {
  late String mnemonic;
  late String networkURL;

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
    final accountsProv = ref.read(accountsProvider.notifier);

    // Create the account
    accountsProv.importWallet(mnemonic, networkURL).then((_) {
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
