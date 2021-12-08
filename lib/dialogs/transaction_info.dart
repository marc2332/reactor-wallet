import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/store.dart';

Future<void> transactionInfo(
  BuildContext context,
  Transaction transaction,
) async {
  bool toMe = transaction.receivedOrNot;
  String involvedAddress = toMe ? transaction.origin : transaction.destination;

  String involvedAddressShort = involvedAddress.toString().substring(0, 13);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Transaction'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                title: const Text('Ammount'),
                subtitle: Text('${transaction.ammount} SOL'),
              ),
              ListTile(
                title: toMe ? const Text('Received from') : const Text('Sent to'),
                subtitle: Text('$involvedAddressShort...'),
                trailing: IconButton(
                  icon: Icon(Icons.copy_all_outlined),
                  onPressed: () {
                    Clipboard.setData(
                      new ClipboardData(text: involvedAddress),
                    ).then(
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Address copied to clipboard"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
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
