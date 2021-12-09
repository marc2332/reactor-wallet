import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/dialogs/send_transaction.dart';
import 'package:solana_wallet/dialogs/transaction_info.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/store.dart';
import 'package:solana_wallet/state/wallet_account.dart';
import 'package:tuple/tuple.dart';
import 'package:cached_network_image/cached_network_image.dart';

String balanceShorter(String balance) {
  if (balance.length >= 6) {
    balance = balance.substring(0, 6);
  }
  return balance;
}

class UnsupportedTransactionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.block_outlined),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('Unsupported transaction'),
            )
          ],
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard(this.transaction);

  @override
  Widget build(BuildContext context) {
    bool toMe = transaction.receivedOrNot;
    String shortAddress =
        toMe ? transaction.origin.substring(0, 5) : transaction.destination.substring(0, 5);
    return Card(
      child: InkWell(
        splashColor: Theme.of(context).hoverColor,
        onTap: () {
          transactionInfo(context, transaction);
        },
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              toMe ? Icon(Icons.call_received_outlined) : Icon(Icons.call_made_outlined),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                    '${toMe ? '+' : '-'}${transaction.ammount.toString()} SOL ${toMe ? 'from' : 'to'} $shortAddress...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WrapperImage extends StatelessWidget {
  final String url;

  WrapperImage(this.url);

  @override
  Widget build(BuildContext context) {
    RegExp isImage = RegExp(r'[\/.](jpg|jpeg|png)', caseSensitive: true);
    if (isImage.hasMatch(url)) {
      return CachedNetworkImage(
        imageUrl: url,
        height: 30,
        width: 30,
        errorWidget: (context, url, error) => const Icon(Icons.no_accounts_outlined),
      );
    } else {
      return Container(width: 30, height: 30, child: const Icon(Icons.no_accounts_outlined));
    }
  }
}

class TokenCard extends StatelessWidget {
  final Token token;

  const TokenCard(this.token);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TokenInfo>(converter: ((store) {
      TokenInfo tokenInfo = store.state.valuesTracker.getTokenInfo(token.mint);
      return tokenInfo;
    }), builder: (context, tokenInfo) {
      String usdBalance = balanceShorter(token.usdBalance);
      String tokenBalance = balanceShorter(token.balance.toString());
      return Card(
        child: InkWell(
          splashColor: Theme.of(context).hoverColor,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: WrapperImage(tokenInfo.logoUrl),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tokenInfo.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(tokenBalance),
                  ],
                ),
                Expanded(child: SizedBox()),
                Container(
                  child: Text('$usdBalance\$'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class BodyTabs extends StatefulWidget {
  final String accountName;

  BodyTabs(this.accountName);

  @override
  BodyTabsState createState() => BodyTabsState(this.accountName);
}

class BodyTabsState extends State<BodyTabs> with SingleTickerProviderStateMixin {
  final accountName;
  late TabController tabsController;

  BodyTabsState(this.accountName);

  @override
  void initState() {
    super.initState();
    tabsController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TabBar(
          controller: tabsController,
          indicatorColor: Theme.of(context).indicatorColor,
          labelColor: Theme.of(context).indicatorColor,
          unselectedLabelColor: Colors.black54,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              text: "Tokens",
            ),
            Tab(
              text: "Transactions",
            )
          ],
        ),
        Container(
          height: 300,
          child: TabBarView(
            controller: tabsController,
            children: <Widget>[
              StoreConnector<AppState, List<Token>>(converter: ((store) {
                Account? account = store.state.accounts[accountName];
                if (account != null) {
                  return account.tokens;
                } else {
                  return [];
                }
              }), builder: (context, tokens) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: tokens.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return TokenCard(tokens[index]);
                    },
                  ),
                );
              }),
              StoreConnector<AppState, List<Transaction>>(converter: ((store) {
                Account? account = store.state.accounts[accountName];
                if (account != null) {
                  return account.transactions;
                } else {
                  return [];
                }
              }), builder: (context, transactions) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final Transaction tx = transactions[index];
                      if (tx.origin != "Unknown") {
                        return TransactionCard(tx);
                      } else {
                        return UnsupportedTransactionCard();
                      }
                    },
                  ),
                );
              })
            ],
          ),
        )
      ],
    );
  }
}

class HomeTabBody extends StatefulWidget {
  HomeTabBody({Key? key, required this.account, required this.store}) : super(key: key);

  final StateWrapper store;
  final Account account;

  @override
  HomeTabBodyState createState() => HomeTabBodyState(this.account, this.store);
}

class HomeTabBodyState extends State<HomeTabBody> {
  final StateWrapper store;

  late String accountName;
  late AccountType accountType;
  late String address;

  HomeTabBodyState(Account account, this.store) {
    this.accountName = account.name;
    this.accountType = account.accountType;
    this.address = account.address;
  }
  @override
  Widget build(BuildContext context) {
    // Convert the account's type to String
    String accountTypeText = "";
    if (accountType == AccountType.Client) {
      accountTypeText = "Watcher";
    } else {
      accountTypeText = "Wallet";
    }
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: () {
              // Copy the account's address to the clipboard
              Clipboard.setData(
                new ClipboardData(text: address),
              ).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Address copied to clipboard"),
                  ),
                );
              });
            },
            child: Text(
              '$accountTypeText (${address.substring(0, 5)}...)',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the account's SOL ammount
                StoreConnector<AppState, String>(converter: ((store) {
                  Account? account = store.state.accounts[accountName];
                  if (account != null) {
                    return balanceShorter(account.balance.toString());
                  } else {
                    return "0";
                  }
                }), builder: (context, solBalance) {
                  return Text(
                    solBalance,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  );
                }),
                const Text(' SOL'),
              ],
            ),
          ),
          StoreConnector<AppState, Tuple2<bool, String>>(converter: ((store) {
            Account? account = store.state.accounts[accountName];
            if (account != null) {
              String usdBalance = balanceShorter(account.usdBalance.toString());
              /*
               * If the SOL balance is 0.0 the USD equivalent will always be 0.0 too, so,
               * in order to prevent an infinite loading animation, it makes sure that the SOL balance is at least > 0.0, 
               * if not, it will just display 0.0
               */
              bool shouldRenderSpinner = account.balance > 0.0 && account.usdBalance == 0.0;
              return Tuple2(shouldRenderSpinner, usdBalance);
            } else {
              return Tuple2(false, "");
            }
          }), builder: (context, value) {
            bool shouldRenderSpinner = value.item1;
            String usdBalance = value.item2;

            if (shouldRenderSpinner) {
              return Container(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  semanticsLabel: 'Loading SOL USD equivalent value',
                ),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$usdBalance\$',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                ],
              );
            }
          }),
          if (accountType == AccountType.Wallet) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text("Send"),
                    onPressed: () {
                      Account? account = store.state.accounts[accountName];
                      if (account != null) {
                        WalletAccount walletAccount = account as WalletAccount;

                        sendTransactionDialog(store, context, walletAccount);
                      }
                    },
                  )
                ],
              ),
            )
          ] else ...[
            SizedBox(height: 15)
          ],
          BodyTabs(accountName)
        ],
      ),
    );
  }
}
