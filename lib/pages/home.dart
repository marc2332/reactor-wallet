import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/account_home.dart';
import 'package:solana_wallet/components/accounts_transaction.dart';
import 'package:solana_wallet/dialogs/send_transaction.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/client_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/wallet_account.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

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
            value: selectedAccount,
            icon: Padding(
              padding: EdgeInsets.only(left: 10),
              child: const Icon(Icons.arrow_downward, color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            onChanged: (Account? account) {
              if (account != null) {
                ref.read(selectedAccountProvider.notifier).state = account;
              }
            },
            items: accounts.map<DropdownMenuItem<Account>>((Account account) {
              return DropdownMenuItem<Account>(
                value: account,
                child: Text(
                  account.name,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return accounts.map<DropdownMenuItem<Account>>((Account account) {
                return DropdownMenuItem<Account>(
                  value: account,
                  child: Text(
                    account.name,
                    style: const TextStyle(color: Colors.white),
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
                sendTransactionDialog(context, selectedAccount);
              },
              child: const Icon(Icons.payment),
            )
          : null,
      body: accountBody,
    );
  }
}

/*
 * Settings sub page
 */
class SettingsSubPage extends ConsumerStatefulWidget {
  SettingsSubPage({Key? key}) : super(key: key);

  @override
  SettingsSubPageState createState() => SettingsSubPageState();
}

class SettingsSubPageState extends ConsumerState<SettingsSubPage> {
  SettingsSubPageState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 20, right: 20),
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Card(
            child: InkWell(
              splashColor: Theme.of(context).hoverColor,
              onTap: () async {
                Navigator.pushNamed(context, '/manage_accounts');
              },
              child: ListTile(
                title: const Text('Manage accounts'),
                trailing: Icon(Icons.manage_accounts_outlined),
              ),
            ),
          ),
          Card(
            child: InkWell(
              splashColor: Theme.of(context).hoverColor,
              onTap: () async {
                openURL('https://github.com/marc2332/solana-mobile-wallet');
              },
              child: ListTile(
                title: const Text('Contribute'),
                trailing: Icon(Icons.link_outlined),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Made by Marc Espín'),
              trailing: Icon(Icons.info_outline),
            ),
          )
        ],
      ),
    );
  }

  void openURL(url) async {
    bool canOpen = await canLaunch(url);

    if (canOpen) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not open browser."),
        ),
      );
    }
  }
}

/*
 * Home Page
 */
class HomePage extends ConsumerStatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (currentPage) {
      // Settings sub page
      case 2:
        page = SettingsSubPage();
        break;

      // Settings sub page
      case 1:
        page = AccountSubPage("/transactions");
        break;

      // Account sub page
      default:
        page = AccountSubPage("/home");
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int page) {
          setState(() {
            currentPage = page;
          });
        },
        elevation: 0,
        currentIndex: currentPage,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.account_balance_wallet),
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.timeline),
            icon: Icon(Icons.timeline),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
