import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/error_popup.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';

/*
 * Apply changes to a account
 */
void applyAccount(Account account, WidgetRef ref, String accountName) {
  final accountsProv = ref.read(accountsProvider.notifier);
  accountsProv.renameAccount(account, accountName);
}

Future<void> editAccountDialog(BuildContext context, Account account) async {
  String accountName = account.name;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, _) {
          return AlertDialog(
            title: Text('Editing ${account.name}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Empty name';
                      } else {
                        return null;
                      }
                    },
                    initialValue: account.name,
                    decoration: InputDecoration(
                      hintText: account.name,
                    ),
                    onChanged: (String value) async {
                      accountName = value;
                    },
                  )
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
              TextButton(
                child: const Text('Apply'),
                onPressed: () {
                  try {
                    applyAccount(account, ref, accountName);
                    Navigator.of(context).pop();
                  } on AccountAlreadyExists {
                    errorMessage(
                      context,
                      "Can't rename account",
                      "An account with name '$accountName' already exists",
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
