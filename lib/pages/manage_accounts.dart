import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/dialogs/editing_account.dart';
import 'package:solana_wallet/dialogs/account_info.dart';
import 'package:solana_wallet/dialogs/remove_account.dart';
import 'package:solana_wallet/state/base_account.dart';
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
                        editAccountDialog(context, store, account);
                      },
                    ),
                    enableFeedback: true,
                    title:
                        Text('${account.name} (${account.address.toString().substring(0, 5)}...)'),
                    leading: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        removeAccountDialog(store, context, account);
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
}
