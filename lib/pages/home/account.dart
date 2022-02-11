import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/account_home.dart';
import 'package:reactor_wallet/components/accounts_transaction.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/dialogs/select_transaction_method.dart';
import 'package:reactor_wallet/components/account_collectibles.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/client_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:shimmer/shimmer.dart';
import 'package:reactor_wallet/utils/theme.dart';

/*
 * Sidebar - alternative to appbar on Desktop
 */
class SideBar extends HookConsumerWidget {
  final List<Account> accounts;
  final ScrollController listController = ScrollController();

  SideBar({Key? key, required this.accounts}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccount = ref.watch(selectedAccountProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(10),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color.fromARGB(100, 0, 0, 0),
            ),
          ],
        ),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: ListView(
                controller: listController,
                children: accounts.map((Account account) {
                  IconData icon = account.accountType == AccountType.Wallet
                      ? Icons.account_balance_wallet_outlined
                      : Icons.person_pin_outlined;
                  return SizedBox(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      splashColor: Theme.of(context).primaryColorLight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              icon,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                              color: selectedAccount == account
                                  ? Theme.of(context).selectedTextColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              account.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        ref.read(selectedAccountProvider.notifier).state = account;
                      },
                    ),
                    height: 80,
                  );
                }).toList(),
              ),
            ),
            if (Platform.isWindows) ...[
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  height: 50,
                  shape: const CircleBorder(),
                  onPressed: () {
                    // Refresh the account when pulling down
                    final accountsProv = ref.read(accountsProvider.notifier);
                    final selectedAccount = ref.read(selectedAccountProvider);
                    if (selectedAccount != null) {
                      accountsProv.refreshAccount(selectedAccount.name);
                    }
                  },
                  child: const Icon(Icons.refresh_outlined, color: Colors.white),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

/*
 * Accounts sub page
 */
class AccountSubPage extends ConsumerWidget {
  final String route;

  const AccountSubPage(this.route, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensTracker = ref.read(tokensTrackerProvider);
    final accounts = ref.watch(accountsProvider).values.toList();

    final selectedAccount = ref.watch(selectedAccountProvider);
    final isAppLoaded = ref.watch(appLoadedProvider);

    Widget? accountBody;
    Widget? accountHeader;

    // If the account is loaded and no account is found then open the Account Selection page in order to create an account
    if (isAppLoaded && selectedAccount == null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/account_selection");
      });
    }

    if (selectedAccount != null) {
      accountHeader = InkWell(
        borderRadius: BorderRadius.circular(5),
        // Disable ripple effect on Windows
        onTap: Platform.isWindows ? null : () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      padding: const EdgeInsets.only(right: 15),
                      child: Icon(icon, color: Theme.of(context).iconColor),
                    ),
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              );
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
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(icon, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          account.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
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
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    }

    if (selectedAccount != null) {
      switch (route) {
        case "/transactions":
          accountBody = AccountTransactions(
            key: Key(selectedAccount.name),
            account: selectedAccount,
          );
          break;

        case "/collectibles":
          accountBody = AccountCollectibles(
            key: Key(selectedAccount.name),
            account: selectedAccount,
          );
          break;

        default:
          accountBody = AccountHome(account: selectedAccount);
          break;
      }
    } else {
      final sampleAccount = ClientAccount("_____", 0, "_____", NetworkUrl("", ""), tokensTracker);

      sampleAccount.isLoaded = false;

      accountBody = AccountHome(
        account: sampleAccount,
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: screenSize.width < 600
          ? AppBar(
              title: accountHeader,
              toolbarHeight: kToolbarHeight + 10,
              actions: Platform.isWindows
                  ? [
                      IconButton(
                        onPressed: () async {
                          if (selectedAccount != null) {
                            final accountsProv = ref.read(accountsProvider.notifier);
                            await accountsProv.refreshAccount(selectedAccount.name);
                          }
                        },
                        icon: const Icon(Icons.refresh_outlined),
                      )
                    ]
                  : null,
            )
          : null,
      floatingActionButton: selectedAccount is WalletAccount
          ? FloatingActionButton(
              tooltip: "Make a transaction",
              onPressed: () {
                selectTransactionMethod(context, selectedAccount);
              },
              child: const Icon(Icons.payment_outlined, color: Colors.white),
            )
          : null,
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (screenSize.width >= 600) ...[
              SideBar(accounts: accounts),
            ],
            Expanded(
              flex: 1,
              child: ResponsiveSizer(triggerWidth: 700, child: accountBody),
            )
          ],
        ),
      ),
    );
  }
}
