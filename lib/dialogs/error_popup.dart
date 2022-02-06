import 'package:flutter/material.dart';

Future<void> errorMessage(context, String title, String content) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
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
                  Text(content),
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
