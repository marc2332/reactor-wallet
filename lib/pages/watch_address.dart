import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/network_selector.dart';
import 'package:solana_wallet/state/states.dart';

/*
 * Getting Started Page
 */
class WatchAddress extends ConsumerStatefulWidget {
  WatchAddress({Key? key}) : super(key: key);

  @override
  WatchAddressState createState() => WatchAddressState();
}

class WatchAddressState extends ConsumerState<WatchAddress> {
  late String address;
  late String networkURL;

  WatchAddressState();

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
                    child: Column(
                      children: [
                        TextFormField(
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
    final accountsProv = ref.read(accountsProvider.notifier);

    // Create the account
    accountsProv.createWatcher(address, networkURL).then((account) {
      ref.read(selectedAccountProvider.notifier).state = account;
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
