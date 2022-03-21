import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/dialogs/error_popup.dart';
import 'package:reactor_wallet/utils/states.dart';

/*
 * Getting Started Page
 */
class CreateWallet extends ConsumerStatefulWidget {
  const CreateWallet({Key? key}) : super(key: key);

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
    final accountsManager = ref.read(accountsProvider.notifier);

    accountName = accountsManager.generateAccountName();

    return Scaffold(
      appBar: AppBar(title: const Text('Create wallet')),
      body: ResponsiveSizer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                      child: Text("Think a name, don't worry, you can change it later."),
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
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
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
                        child: Text("Create Wallet"),
                      ),
                      onPressed: createWallet,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createWallet() async {
    final accountsProv = ref.read(accountsProvider.notifier);

    if (accountName.isNotEmpty) {
      try {
        await accountsProv.createWallet(accountName, networkURL);

        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      } catch (err) {
        errorMessage(
          context,
          "Can't create account",
          "An account with name '$accountName' already exists",
        );
      }
    } else {
      errorMessage(
        context,
        "Empty name",
        "The account must have a name",
      );
    }
  }
}
