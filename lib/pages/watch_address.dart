import 'package:flutter/material.dart';
import '../state/store.dart';

/*
 * Getting Started Page
 */
class WatchAddress extends StatefulWidget {
  WatchAddress({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  WatchAddressState createState() => WatchAddressState(this.store);
}

class WatchAddressState extends State<WatchAddress> {
  StateWrapper store;
  late String address;

  WatchAddressState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch an address')),
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
                        } else if (value.length < 43 || value.length > 50) {
                          return 'Address length is not correct';
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
              ElevatedButton(
                child: const Text("Continue"),
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
    store.createWatcher(address).then((_) {
      // Go to Home page
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
