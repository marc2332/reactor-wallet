import 'package:flutter/material.dart';

Future<void> paymentErrorDialog(context, String destination, double ammount) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Transaction error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(
                      Icons.error_outline_outlined,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                  Text("Could not sent $ammount SOL to"),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      destination,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
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
