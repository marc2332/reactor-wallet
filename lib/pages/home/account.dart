import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/account_home.dart';
import 'package:solana_wallet/components/accounts_transaction.dart';
import 'package:solana_wallet/dialogs/select_transaction_method.dart';
import 'package:solana_wallet/utils/base_account.dart';
import 'package:solana_wallet/utils/client_account.dart';
import 'package:solana_wallet/utils/states.dart';
import 'package:solana_wallet/utils/tracker.dart';
import 'package:solana_wallet/utils/wallet_account.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solana_wallet/utils/theme.dart';

/*
 * Accounts sub page
 */
class AccountSubPage extends ConsumerWidget {
  final String route;

  AccountSubPage(this.route);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensTracker = ref.read(tokensTrackerProvider);
    final accounts = ref.watch(accountsProvider).values.toList();

    final selectedAccount = ref.watch(selectedAccountProvider);
    final isAppLoaded = ref.watch(appLoadedProvider);

    Widget? accountBody;
    Widget? accountHeader;

    if (isAppLoaded && selectedAccount == null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/account_selection");
      });
    }

    if (selectedAccount != null) {
      accountHeader = InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<Account>(
            iconSize: 20,
            value: selectedAccount,
            icon: const Icon(Icons.arrow_downward, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            onChanged: (Account? account) {
              if (account != null) {
                ref.read(selectedAccountProvider.notifier).state = account;
              }
            },
            items: accounts.map<DropdownMenuItem<Account>>((Account account) {
              IconData icon = account.accountType == AccountType.Wallet
                  ? Icons.account_balance_wallet_outlined
                  : Icons.person_pin_outlined;
              return DropdownMenuItem<Account>(
                  value: account,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(icon, color: Theme.of(context).iconColor),
                      ),
                      Text(
                        account.name,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ));
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return accounts.map<DropdownMenuItem<Account>>((Account account) {
                IconData icon = account.accountType == AccountType.Wallet
                    ? Icons.account_balance_wallet_outlined
                    : Icons.person_pin_outlined;
                return DropdownMenuItem<Account>(
                    value: account,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(icon, color: Colors.white),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            account.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ),
      );
    } else {
      accountHeader = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 75,
          height: 30,
          decoration: BoxDecoration(
            color: Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }

    if (selectedAccount != null) {
      if (route == "/home") {
        accountBody = AccountHome(
          key: Key(selectedAccount.name),
          account: selectedAccount,
        );
      } else {
        accountBody = AccountTransactions(
          key: Key(selectedAccount.name),
          account: selectedAccount,
        );
      }
    } else {
      final sampleAccount = ClientAccount("_____", 0, "_____", "_____", tokensTracker);

      sampleAccount.isLoaded = false;

      accountBody = AccountHome(
        account: sampleAccount,
      );
    }

    return Scaffold(
      appBar: AppBar(title: accountHeader),
      floatingActionButton: selectedAccount is WalletAccount
          ? FloatingActionButton(
              onPressed: () {
                selectTransactionMethod(context, selectedAccount);
              },
              child: const Icon(Icons.payment, color: Colors.white),
            )
          : null,
      body: accountBody,
    );
  }
}
