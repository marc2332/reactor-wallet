import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/theme.dart';

Future<void> paymentInfo(
  BuildContext context,
  TransactionDetails transaction,
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
                title: const Text('Amount'),
                subtitle: Text('${transaction.ammount.toStringAsFixed(9)} SOL'),
              ),
              ListTile(
                title: toMe ? const Text('Received from') : const Text('Sent to'),
                subtitle: Text('$involvedAddressShort...'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.copy_all_outlined,
                    color: Theme.of(context).iconColor,
                  ),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: involvedAddress),
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
