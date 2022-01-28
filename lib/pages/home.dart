import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/home_tab_body.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/client_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/wallet_account.dart';
import '../state/tracker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class AccountSubPage extends StatefulWidget {
  const AccountSubPage({Key? key}) : super(key: key);
  @override
  State<AccountSubPage> createState() => AccountSubPageState();
}

/*
 * Accounts sub page
 */
class AccountSubPageState extends State<AccountSubPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final tokensTracker = ref.read(tokensTrackerProvider);
        final accounts = ref.watch(accountsProvider).values.toList();

        final isAppLoaded = ref.watch(appLoaded);

        List<Widget> accountTabs = [];
        List<Widget> accountBodies = [];

        if (isAppLoaded) {
          accountTabs = accounts.map(
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
          ).toList();
        } else {
          accountTabs = [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Tab(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(150, 0, 0, 0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        }

        if (isAppLoaded) {
          accountBodies = accounts.map((account) {
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh all account's balances when pulling
                final accountsProv = ref.read(accountsProvider.notifier);
                await accountsProv.refreshAccounts();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: HomeTabBody(
                  account: account,
                ),
              ),
            );
          }).toList();
        } else {
          final sampleAccount = ClientAccount("_____", 0, "_____", "_____", tokensTracker);

          sampleAccount.isLoaded = false;

          accountBodies = [
            RefreshIndicator(
              onRefresh: () async {
                // Refresh all account's balances when pulling
                final accountsProv = ref.read(accountsProvider.notifier);
                await accountsProv.refreshAccounts();
              },
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  // This disables the Material scroll effect when overscrolling
                  overscroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: HomeTabBody(
                    account: sampleAccount,
                  ),
                ),
              ),
            )
          ];
        }

        return DefaultTabController(
          length: accountBodies.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Accounts"),
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
                  tabs: accountTabs,
                ),
              ),
            ),
            body: TabBarView(
              physics: BouncingScrollPhysics(),
              children: accountBodies,
            ),
          ),
        );
      },
    );
  }
}

/*
 * Settings sub page
 */
class SettingsSubPage extends ConsumerStatefulWidget {
  SettingsSubPage();

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
      case 1:
        page = SettingsSubPage();
        break;

      // Wallet sub page
      default:
        page = AccountSubPage();
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
  }
}
