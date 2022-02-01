import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/dialogs/transaction_errored.dart';
import 'package:solana_wallet/dialogs/transaction_sent.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/wallet_account.dart';
import 'package:worker_manager/worker_manager.dart';

Future<bool> makeTransaction(WalletAccount account, String destination, int supply) async {
  try {
    account.sendLamportsTo(destination, supply);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> sendTransaction(WalletAccount walletAccount, String destination, int lamports) {
  return Executor().execute(
    arg1: walletAccount,
    arg2: destination,
    arg3: lamports,
    fun3: makeTransaction,
  );
}

Future<void> prepareTransaction(
  BuildContext context,
  Transaction transaction,
  WalletAccount walletAccount,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Send this transaction?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                title: const Text('From'),
                subtitle: Text(transaction.origin),
              ),
              ListTile(
                title: const Text('Amount'),
                subtitle: Text('${transaction.ammount.toStringAsFixed(9)} SOL'),
              ),
              ListTile(
                title: const Text('Send to'),
                subtitle: Text(transaction.destination),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Consumer(builder: (context, ref, child) {
            return TextButton(
              child: const Text('Send'),
              onPressed: () {
                Navigator.of(context).pop();

                // Show some feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Sending ${transaction.ammount} SOL to ${transaction.destination.substring(0, 5)}...'),
                  ),
                );

                // Convert SOL to lamport
                int lamports = (transaction.ammount * 1000000000).toInt();

                sendTransaction(walletAccount, transaction.destination, lamports).then((res) async {
                  if (res) {
                    final accountsProv = ref.read(accountsProvider.notifier);

                    // Display the "Transaction went OK" dialog
                    await transactionHasBeenSentDialog(
                      context,
                      transaction.destination,
                      transaction.ammount,
                    );

                    accountsProv.refreshAccount(walletAccount.name);
                  } else {
                    // Display the "Transaction went wrong" dialog
                    await transactionErroredDialog(
                      context,
                      transaction.destination,
                      transaction.ammount,
                    );
                  }
                });
              },
            );
          })
        ],
      );
    },
  );
}
