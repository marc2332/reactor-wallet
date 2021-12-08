import 'package:flutter/material.dart';
import 'package:solana_wallet/components/network_selector.dart';
import '../state/store.dart';

/*
 * Getting Started Page
 */
class CreateWallet extends StatefulWidget {
  CreateWallet({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  CreateWalletState createState() => CreateWalletState(this.store);
}

class CreateWalletState extends State<CreateWallet> {
  StateWrapper store;
  late String address;
  late String accountName;
  late String networkURL;

  CreateWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create wallet')),
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
                              return 'Empty account name';
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter an account name',
                          ),
                          onChanged: (String value) async {
                            accountName = value;
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
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Create Wallet"),
                onPressed: createWallet,
              )
            ],
          )
        ],
      ),
    );
  }

  void createWallet() async {
    if (accountName.length > 0 && !store.state.accounts.containsKey(accountName)) {
      store.createWallet(accountName, networkURL).then((_) {
        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    }
  }
}
