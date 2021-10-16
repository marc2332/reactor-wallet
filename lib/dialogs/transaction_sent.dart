import 'package:flutter/material.dart';

Future<void> transactionHasBeenSentDialog(
    context, String destination, double ammount) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Transaction sent'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(
                      Icons.task_alt_outlined,
                      color: Colors.green,
                      size: 35,
                    ),
                  ),
                  Text("Successfully sent $ammount SOL to"),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "$destination",
                      style: TextStyle(
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
