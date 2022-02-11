import 'package:flutter/material.dart';

Future<void> paymentNotSupportedDialog(context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Transaction not supported'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(
                      Icons.error_outline_outlined,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                  Text("Unfortunately, token payments are not supported yet."),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () async {
              // Close the dialog
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
