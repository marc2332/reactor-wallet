import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/components/home_tab_body.dart';
import '../state/store.dart';

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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Account>>(converter: (store) {
      Map<String, Account> accounts = store.state.accounts;
      return accounts.entries.map((entry) => entry.value).toList();
    }, builder: (context, accounts) {
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
                      removeAccount(currentAccount);
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
    });
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
}
