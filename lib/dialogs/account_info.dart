import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:reactor_wallet/utils/theme.dart';

Future<void> accountInfoDialog(context, Account account) async {
  String shortAddress = account.address.substring(0, 13);
  NetworkUrl network = account.url;
  String accountType = account.accountType == AccountType.Client ? 'Client' : 'Wallet';

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(account.name),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                title: const Text('Address'),
                subtitle: Text('$shortAddress...'),
                trailing: IconButton(
                  icon: Icon(Icons.copy_all_outlined, color: Theme.of(context).iconColor),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: account.address),
                    ).then(
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Address copied to clipboard"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ListTile(
                title: const Text('Network'),
                subtitle: Text(network.rpc),
              ),
              ListTile(
                title: const Text('Account type'),
                subtitle: Text(accountType),
              ),
              if (account.accountType == AccountType.Wallet) ...[
                ListTile(
                  title: const Text('Seedphrase'),
                  subtitle: const Text('Hidden'),
                  trailing: IconButton(
                    icon: Icon(Icons.copy_all_outlined, color: Theme.of(context).iconColor),
                    onPressed: () {
                      WalletAccount walletAccount = account as WalletAccount;

                      // Copy the account's seedphrase to the clipboard
                      Clipboard.setData(
                        ClipboardData(text: walletAccount.mnemonic),
                      ).then(
                        (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Address copied to clipboard"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ]
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
