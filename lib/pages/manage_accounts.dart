import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/state/store.dart';

class ManageAccountsPage extends StatefulWidget {
  final StateWrapper store;

  ManageAccountsPage({Key? key, required this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ManageAccountsPageState(this.store);
}

class ManageAccountsPageState extends State<ManageAccountsPage> {
  final StateWrapper store;

  ManageAccountsPageState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add_alt_1_outlined),
        onPressed: () {
          Navigator.pushNamed(context, "/account_selection");
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: StoreConnector<AppState, List<Account>>(
          converter: (store) {
            Map<String, Account> accounts = store.state.accounts;
            return accounts.entries.map((entry) => entry.value).toList();
          },
          builder: (context, accounts) {
            return ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: accounts.map((account) {
                return Card(
                  child: ListTile(
                    subtitle: Text("Press for more info"),
                    trailing: IconButton(
                      icon: Icon(Icons.mode_edit_outline_outlined),
                      onPressed: () {
                        editAccountDialog(context, account);
                      },
                    ),
                    enableFeedback: true,
                    title: Text(
                        '${account.name} (${account.address.toString().substring(0, 5)}...)'),
                    leading: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        removeAccountDialog(context, account);
                      },
                    ),
                    onTap: () {
                      accountInfoDialog(context, account);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  /*
   * Remove an account by passing it's instance
   */
  void removeAccount(Account account) {
    store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});

    if (store.state.accounts.length == 0) {
      Navigator.pushReplacementNamed(context, "/account_selection");
    }
  }

  /*
   * Apply changes to a new account
   */
  void applyAccount(Account account, String accountName) {
    store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});
    account.name = accountName;
    store.dispatch({"type": StateActions.AddAccount, "account": account});
  }

  Future<void> editAccountDialog(context, account) async {
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
                applyAccount(account, accountName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> accountInfoDialog(context, Account account) async {
    String shortAddress = account.address.substring(0, 5);
    String network = account.url;
    String accountType =
        account.accountType == AccountType.Client ? 'Client' : 'Wallet';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(account.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Address ($shortAddress...)'),
                  subtitle: const Text('Press to copy'),
                  onTap: () {
                    // Copy the account's address to the clipboard
                    Clipboard.setData(
                      new ClipboardData(text: account.address),
                    ).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Address copied to clipboard"),
                        ),
                      );
                    });
                  },
                ),
                ListTile(
                  title: const Text('Network'),
                  subtitle: Text(network),
                ),
                ListTile(
                  title: const Text('Account type'),
                  subtitle: Text(accountType),
                ),
                if (account.accountType == AccountType.Wallet) ...[
                  ListTile(
                    title: const Text('Seedphrase'),
                    subtitle: const Text('Press to copy'),
                    onTap: () {
                      WalletAccount walletAccount = account as WalletAccount;

                      // Copy the account's seedphrase to the clipboard
                      Clipboard.setData(
                        new ClipboardData(text: walletAccount.mnemonic),
                      ).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Seedphrase copied to clipboard"),
                          ),
                        );
                      });
                    },
                  )
                ]
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

  Future<void> removeAccountDialog(context, account) async {
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
                removeAccount(account);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
