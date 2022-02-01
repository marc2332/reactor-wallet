import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/dialogs/prepare_transaction.dart';
import 'package:solana_wallet/dialogs/transaction_errored.dart';
import 'package:solana_wallet/dialogs/transaction_sent.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/wallet_account.dart';
import 'package:worker_manager/worker_manager.dart';

String? transactionAddressValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Empty address';
  }
  if (value.length < 43 || value.length > 50) {
    return 'Address length is not correct';
  } else {
    return null;
  }
}

String? transactionAmountValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Empty ammount';
  }
  if (double.parse(value) <= 0) {
    return 'You must send at least 0.000000001 SOL';
  } else {
    return null;
  }
}

Future<void> sendTransactionDialog(
  BuildContext context,
  WalletAccount walletAccount,
) async {
  String destination = "";
  double sendAmount = 0;
  String accountName = walletAccount.name;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Consumer(builder: (context, ref, _) {
        return AlertDialog(
          title: const Text('Send SOL'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    validator: transactionAddressValidator,
                    decoration: InputDecoration(
                      hintText: walletAccount.address,
                    ),
                    onChanged: (String value) async {
                      destination = value;
                    },
                  ),
                ),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    validator: transactionAmountValidator,
                    decoration: InputDecoration(
                      hintText: 'Amount of SOLs',
                    ),
                    onChanged: (String value) async {
                      sendAmount = double.parse(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                bool addressIsOk = transactionAddressValidator(destination) == null;
                bool balanceIsOk = transactionAmountValidator("$sendAmount") == null;

                // Only let send if the address and the ammount is OK
                if (addressIsOk && balanceIsOk) {
                  // Close the dialog
                  Navigator.of(dialogContext).pop();

                  Transaction tx =
                      new Transaction(walletAccount.address, destination, sendAmount, false);

                  prepareTransaction(context, tx, walletAccount);
                }
              },
            ),
          ],
        );
      });
    },
  );
}
