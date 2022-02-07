import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/utils/states.dart';

/*
 * Getting Started Page
 */
class ImportWallet extends ConsumerStatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  ImportWalletState createState() => ImportWalletState();
}

class ImportWalletState extends ConsumerState<ImportWallet> {
  late String mnemonic;
  late NetworkUrl networkURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import wallet')),
      body: ResponsiveSizer(
        child: Column(
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
      ),
    );
  }

  void importWallet() async {
    final accountsProv = ref.read(accountsProvider.notifier);

    // Create the account
    accountsProv.importWallet(mnemonic, networkURL).then((account) {
      ref.read(selectedAccountProvider.notifier).state = account;
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
