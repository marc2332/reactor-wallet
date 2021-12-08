import 'package:flutter/material.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/store.dart';

Future<void> removeAccountDialog(StateWrapper store, BuildContext context, Account account) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("'${account.name}' will be permanently removed. "),
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
            child: const Text('Remove'),
            onPressed: () {
              removeAccount(store, context, account);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/*
 * Remove an account by passing it's instance
 */
void removeAccount(StateWrapper store, BuildContext context, Account account) {
  store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});

  if (store.state.accounts.length == 0) {
    Navigator.pushReplacementNamed(context, "/account_selection");
  }
}
