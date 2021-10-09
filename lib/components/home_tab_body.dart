import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solana_wallet/state/store.dart';
import 'package:tuple/tuple.dart';

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
      padding: EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('$accountTypeText (${address.substring(0, 5)}...)'),
          Padding(
            padding: EdgeInsets.all(15),
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
              return Container(
                width: 100,
                height: 35,
                child: Center(
                  child: Text(
                    '$usdBalance\$',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
          if (accountType == AccountType.Wallet) ...[
            MaterialButton(
              child: const Text("Copy seedphrase"),
              onPressed: () {
                copyMnemonic();
              },
            ),
          ],
          MaterialButton(
            child: const Text("Copy address"),
            onPressed: () {
              copyAddress();
            },
          )
        ],
      ),
    );
  }

  /*
   * Copy an account's address
   */
  void copyAddress() {
    Account? account = store.state.accounts[accountName];

    if (account == null) return;

    Clipboard.setData(new ClipboardData(text: account.address)).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Address copied to clipboard")));
    });
  }

  /*
   * Copy the seedphrase of an account
   */
  void copyMnemonic() {
    Account? account = store.state.accounts[accountName];

    if (account == null) return;

    // Only for wallets
    if (account.accountType != AccountType.Wallet) return;

    WalletAccount walletAccount = account as WalletAccount;

    Clipboard.setData(new ClipboardData(text: walletAccount.mnemonic))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mnemonic copied to clipboard")));
    });
  }
}
