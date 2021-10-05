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
              IconButton(
                icon: Icon(
                  Icons.add,
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
                    (account) => Tab(
                      text: account.name,
                    ),
                  )
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: accounts
                .map(
                  (account) => Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        StoreConnector<AppState, String>(converter: (store) {
                          return account.accountType.toString();
                        }, builder: (context, text) {
                          return Text(text);
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StoreConnector<AppState, String>(
                                converter: (store) {
                              String balance = account.balance.toString();
                              if (balance.length >= 5) {
                                return balance.substring(0, 5);
                              } else {
                                return balance;
                              }
                            }, builder: (context, balance) {
                              return Text(balance,
                                  style: TextStyle(fontSize: 50));
                            }),
                            Text(' SOL'),
                          ],
                        ),
                        StoreConnector<AppState, String>(converter: (store) {
                          String usdtBalance = account.usdtBalance.toString();
                          if (usdtBalance.length >= 6) {
                            return usdtBalance.substring(0, 6);
                          } else {
                            return usdtBalance;
                          }
                        }, builder: (context, usdBalance) {
                          return Text('$usdBalance\$',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold));
                        }),
                        MaterialButton(
                          child: Text("Log off"),
                          onPressed: () {
                            logOff(account);
                          },
                        ),
                        MaterialButton(
                          child: Text("copy mnemonic"),
                          onPressed: () {
                            copyMnemonic(account);
                          },
                        ),
                        MaterialButton(
                          child: Text("copy address"),
                          onPressed: () {
                            copyAddress(account);
                          },
                        )
                      ],
                    ),
                  ),
                )
                .toList(),
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

    WalletAccount walletAccount =
        store.state.getCurrentAccount() as WalletAccount;

    Clipboard.setData(new ClipboardData(text: walletAccount.mnemonic))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mnemonic copied to clipboard")));
    });
  }

  void logOff(Account account) {
    Navigator.pushReplacementNamed(context, "/account_selection");

    store.dispatch({"type": StateActions.RemoveAccount, "name": account.name});
  }
}
