import 'package:flutter/material.dart';
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

  CreateWalletState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create wallet')),
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
                      accountName = value;
                    },
                  ),
                ),
              ),
            ),
          ]),
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
    if (accountName.length > 0 &&
        !store.state.accounts.containsKey(accountName)) {
      store.createWallet(accountName).then((_) {
        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    }
  }
}
