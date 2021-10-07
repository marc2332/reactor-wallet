import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../state/store.dart';

/*
 * Home Page
 */
class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  HomePageState createState() => HomePageState(this.store);
}

class HomePageState extends State<HomePage> {
  final store;

  HomePageState(this.store);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Account>>(converter: (store) {
      Map<String, Account> accounts = store.state.accounts;
      List<Account> listedAccounts =
          accounts.entries.map((entry) => entry.value).toList();
      return listedAccounts;
    }, builder: (context, accounts) {
      return DefaultTabController(
        length: accounts.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Solana wallet"),
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
                      logOff(currentAccount);
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
            bottom: TabBar(
              tabs: accounts
                  .map(
                    (account) => Tab(text: account.name),
                  )
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: accounts.map((account) {
              String accountType = "";

              if (account.accountType == AccountType.Client) {
                accountType = "Watcher";
              } else {
                accountType = "Wallet";
              }

              String usdBalance = account.usdtBalance.toString();
              if (usdBalance.length >= 6) {
                usdBalance = usdBalance.substring(0, 6);
              }
              String solBalance = account.balance.toString();
              if (solBalance.length >= 5) {
                solBalance = solBalance.substring(0, 5);
              }
              return Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        '$accountType (${account.address.substring(0, 5)}...)'),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(solBalance, style: TextStyle(fontSize: 50)),
                          Text(' SOL'),
                        ],
                      ),
                    ),
                    Text(
                      '$usdBalance\$',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (account.accountType == AccountType.Wallet) ...[
                      MaterialButton(
                        child: Text("Copy seedphrase"),
                        onPressed: () {
                          copyMnemonic(account);
                        },
                      ),
                    ],
                    MaterialButton(
                      child: Text("Copy address"),
                      onPressed: () {
                        copyAddress(account);
                      },
                    ),
                    Column(
                      children: account.transactions.map((tx) {
                        return Text("tx");
                      }).toList(),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void copyAddress(Account account) {
    Clipboard.setData(new ClipboardData(text: account.address)).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Address copied to clipboard")));
    });
  }

  void copyMnemonic(Account account) {
    // Only for wallets
    if (account.accountType != AccountType.Wallet) return;

    WalletAccount walletAccount = account as WalletAccount;

    Clipboard.setData(new ClipboardData(text: walletAccount.mnemonic))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mnemonic copied to clipboard")));
    });
  }

  void logOff(Account account) {
    store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});

    if (store.state.accounts.length == 0) {
      Navigator.pushReplacementNamed(context, "/account_selection");
    }
  }
}
