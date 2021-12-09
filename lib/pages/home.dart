import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/components/home_tab_body.dart';
import 'package:solana_wallet/state/base_account.dart';
import '../state/store.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 * Accounts sub page
 */
class AccountSubPage extends StatelessWidget {
  final StateWrapper store;
  final List<Account> accounts;

  AccountSubPage(this.store, this.accounts);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: accounts.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wallets"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.manage_accounts_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/manage_accounts");
              },
            )
          ],
          bottom: new PreferredSize(
            preferredSize: new Size(200.0, 50.0),
            child: TabBar(
              physics: BouncingScrollPhysics(),
              isScrollable: true,
              tabs: accounts.map(
                (account) {
                  bool isWallet = account.accountType == AccountType.Wallet;
                  IconData icon =
                      isWallet ? Icons.account_balance_wallet_outlined : Icons.person_pin_outlined;

                  return Tab(
                    child: Row(
                      children: [
                        Icon(icon),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(account.name),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: accounts.map((account) {
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh all account's balances when pulling
                await store.refreshAccounts();
              },
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  // This disables the Material scroll effect when overscrolling
                  overscroll.disallowGlow();
                  return true;
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: HomeTabBody(
                    account: account,
                    store: store,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/*
 * Settings sub page
 */
class SettingsSubPage extends StatefulWidget {
  final StateWrapper store;

  SettingsSubPage(this.store);

  @override
  State<StatefulWidget> createState() => SettingsSubPageState(this.store);
}

class SettingsSubPageState extends State<SettingsSubPage> {
  final StateWrapper store;

  SettingsSubPageState(this.store);

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
class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  HomePageState createState() => HomePageState(this.store);
}

class HomePageState extends State<HomePage> {
  final StateWrapper store;

  HomePageState(this.store);

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Account>>(converter: (store) {
      Map<String, Account> accounts = store.state.accounts;
      return accounts.entries.map((entry) => entry.value).toList();
    }, builder: (context, accounts) {
      Widget page;

      switch (currentPage) {
        // Settings sub page
        case 1:
          page = SettingsSubPage(store);
          break;

        // Wallet sub page
        default:
          page = AccountSubPage(store, accounts);
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
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }
}
