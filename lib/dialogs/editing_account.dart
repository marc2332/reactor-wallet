import 'package:flutter/material.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/store.dart';

/*
   * Apply changes to a new account
   */
void applyAccount(StateWrapper store, Account account, String accountName) {
  store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});
  account.name = accountName;
  store.dispatch({"type": StateActions.AddAccount, "account": account});
}

Future<void> editAccountDialog(BuildContext context, StateWrapper store, Account account) async {
  String accountName = account.name;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
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
              applyAccount(store, account, accountName);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
