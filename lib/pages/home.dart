import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/components/home_tab_body.dart';
import '../state/store.dart';

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
          title: const Text("Solana wallet"),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  TabController? tabController =
                      DefaultTabController.of(context);
                  if (tabController != null) {
                    int tabIndex = tabController.index;
                    Account currentAccount = accounts[tabIndex];
                    removeAccount(context, store, currentAccount);
                  }
                },
              );
            }),
            IconButton(
              icon: Icon(
                Icons.person_add_alt_1_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/account_selection");
              },
            )
          ],
          bottom: new PreferredSize(
            preferredSize: new Size(200.0, 60.0),
            child: TabBar(
              physics: BouncingScrollPhysics(),
              isScrollable: true,
              tabs: accounts
                  .map(
                    (account) => Tab(text: account.name),
                  )
                  .toList(),
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
                  child: HomeTabBody(account: account, store: store),
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
class SettingsSubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Text("Made by Marc Espín. WIP")],
      ),
    );
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
          page = SettingsSubPage();
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
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Accounts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings')
          ],
        ),
      );
    });
  }
}

/*
   * Remove an account by passing it's instance
   */
void removeAccount(context, store, Account account) {
  store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});

  if (store.state.accounts.length == 0) {
    Navigator.pushReplacementNamed(context, "/account_selection");
  }
}
