import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/dialogs/transaction_errored.dart';
import 'package:solana_wallet/dialogs/transaction_sent.dart';
import 'package:solana_wallet/state/store.dart';
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

String? transactionAmmountValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Empty ammount';
  }
  if (double.parse(value) <= 0) {
    return 'You must send at least 0.000000001 SOL';
  } else {
    return null;
  }
}

Future<bool> makeTransaction(
  Wallet wallet,
  String destination,
  int lamports,
) async {
  try {
    await wallet.transfer(
      destination: destination,
      lamports: lamports,
    );

    return true;
  } catch (e) {
    return false;
  }
}

Future<void> sendTransactionDialog(
  StateWrapper store,
  BuildContext context,
  WalletAccount walletAccount,
) async {
  String destination = "";
  double sendAmmount = 0;
  String accountName = walletAccount.name;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
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
                  validator: transactionAmmountValidator,
                  decoration: InputDecoration(
                    hintText: 'Ammount of SOLs',
                  ),
                  onChanged: (String value) async {
                    sendAmmount = double.parse(value);
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
              bool balanceIsOk = transactionAmmountValidator("$sendAmmount") == null;

              // Only let send if the address and the ammount is OK
              if (addressIsOk && balanceIsOk) {
                // 1 SOL = 1000000000 lamports
                int lamports = (sendAmmount * 1000000000).toInt();
                // Make the transfer
                Wallet wallet = walletAccount.wallet;

                // Close the dialog
                Navigator.of(dialogContext).pop();

                // Show some feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sending $sendAmmount SOL to ${destination.substring(0, 5)}...'),
                  ),
                );

                Executor()
                    .execute(arg1: wallet, arg2: destination, arg3: lamports, fun3: makeTransaction)
                    .then(
                  (res) async {
                    if (res) {
                      store.refreshAccount(accountName);
                      await transactionHasBeenSentDialog(
                        context,
                        destination,
                        sendAmmount,
                      );
                    } else {
                      await transactionErroredDialog(
                        context,
                        destination,
                        sendAmmount,
                      );
                    }
                  },
                );
              }
            },
          ),
        ],
      );
    },
  );
}
