import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/states.dart';

/*
 * Getting Started Page
 */
class CreateWallet extends ConsumerStatefulWidget {
  CreateWallet({Key? key}) : super(key: key);

  @override
  CreateWalletState createState() => CreateWalletState();
}

class CreateWalletState extends ConsumerState<CreateWallet> {
  late String address;
  late String accountName;
  late NetworkUrl networkURL;

  CreateWalletState();

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
                    padding: const EdgeInsets.all(15),
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
                          padding: const EdgeInsets.only(top: 20, bottom: 5),
                          child: NetworkSelector(
                            onSelected: (NetworkUrl? url) {
                              if (url != null) {
                                networkURL = url;
                              }
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
    final accountsProv = ref.read(accountsProvider.notifier);

    if (accountName.length > 0 && !accountsProv.state.containsKey(accountName)) {
      accountsProv.createWallet(accountName, networkURL).then((_) {
        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    }
  }
}
