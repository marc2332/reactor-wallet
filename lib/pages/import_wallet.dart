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
  late String accountName;
  late NetworkUrl networkURL;

  @override
  Widget build(BuildContext context) {
    final accountsManager = ref.read(accountsProvider.notifier);

    accountName = accountsManager.generateAccountName();

    return Scaffold(
      appBar: AppBar(title: const Text('Import wallet')),
      body: ResponsiveSizer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("You can name it as you wish, or change it later"),
                    ),
                    TextFormField(
                      initialValue: accountName,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: "Account name",
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 6, right: 5),
                          child: Icon(Icons.account_box_rounded),
                        ),
                      ),
                      autofocus: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Empty account name';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (String value) async {
                        accountName = value;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          hintText: "Wallet's seedphrase",
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 6, right: 5),
                            child: Icon(Icons.security_rounded),
                          ),
                        ),
                        autofocus: true,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Empty seedphrase';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (String value) async {
                          mnemonic = value;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: NetworkSelector(
                        onSelected: (NetworkUrl? url) {
                          if (url != null) {
                            networkURL = url;
                          }
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Import Wallet"),
                      ),
                      onPressed: importWallet,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void importWallet() async {
    final accountsProv = ref.read(accountsProvider.notifier);

    // Create the account
    accountsProv.importWallet(mnemonic, networkURL, accountName).then((account) {
      ref.read(selectedAccountProvider.notifier).state = account;
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }
}
