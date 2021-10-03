import 'package:flutter/material.dart';
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
  late String address;

  GettingStartedPageState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Getting started')),
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
    WalletAccount account = new WalletAccount(
        address, 0, "Main", "https://api.mainnet-beta.solana.com");

    // Load the balance
    await account.refreshBalance();

    // Add the account
    this.store.dispatch({"type": StateActions.AddAccount, "account": account});

    // Go to Home page
    Navigator.pushReplacementNamed(context, "/home");
  }
}
