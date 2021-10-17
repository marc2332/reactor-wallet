import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana/solana.dart' show Wallet;
import 'package:solana_wallet/dialogs/send_transaction.dart';
import 'package:solana_wallet/dialogs/transaction_info.dart';
import 'package:solana_wallet/state/store.dart';
import 'package:tuple/tuple.dart';
import 'package:worker_manager/worker_manager.dart';

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
    String shortAddress = this.transaction.origin.substring(0, 5);
    bool toMe = transaction.receivedOrNot;
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
              toMe
                  ? Icon(Icons.call_received_outlined)
                  : Icon(Icons.call_made_outlined),
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

class HomeTabBody extends StatefulWidget {
  HomeTabBody({Key? key, required this.account, required this.store})
      : super(key: key);

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
      padding: EdgeInsets.only(top: 20.0),
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
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the account's SOL ammount
                StoreConnector<AppState, String>(converter: ((store) {
                  Account? account = store.state.accounts[accountName];
                  if (account != null) {
                    String solBalance = account.balance.toString();
                    // Cut some numbers to make it easier to read
                    if (solBalance.length >= 5) {
                      solBalance = solBalance.substring(0, 5);
                    }
                    return solBalance;
                  } else {
                    return "0";
                  }
                }), builder: (context, solBalance) {
                  return Text(
                    solBalance,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 50,
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
              String usdBalance = account.usdtBalance.toString();
              // Cut some numbers to make it easier to read
              if (usdBalance.length >= 6) {
                usdBalance = usdBalance.substring(0, 6);
              }
              /*
               * If the SOL balance is 0.0 the USD equivalent will always be 0.0 too, so,
               * in order to prevent an infinite loading animation, it makes sure that the SOL balance is at least > 0.0, 
               * if not, it will just display 0.0
               */
              bool shouldRenderSpinner =
                  account.balance > 0.0 && account.usdtBalance == 0.0;
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
          Padding(
            padding: EdgeInsets.all(30),
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
          ),
          StoreConnector<AppState, List<Transaction?>>(converter: ((store) {
            Account? account = store.state.accounts[accountName];
            if (account != null) {
              return account.transactions;
            } else {
              return [];
            }
          }), builder: (context, transactions) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: transactions.map((tx) {
                  if (tx != null) {
                    return new TransactionCard(tx);
                  } else {
                    return UnsupportedTransactionCard();
                  }
                }).toList(),
              ),
            );
          })
        ],
      ),
    );
  }
}
