import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/dialogs/send_transaction.dart';
import 'package:solana_wallet/dialogs/transaction_info.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/tracker.dart';
import 'package:solana_wallet/state/wallet_account.dart';
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

class TokenCard extends ConsumerWidget {
  final Token token;

  const TokenCard(this.token);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensTracker = ref.watch(tokensTrackerProvider);

    TokenInfo tokenInfo = tokensTracker.getTokenInfo(token.mint);

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
  }
}

class BodyTabs extends StatefulWidget {
  final Account account;

  BodyTabs(this.account);

  @override
  BodyTabsState createState() => BodyTabsState(this.account);
}

class BodyTabsState extends State<BodyTabs> with SingleTickerProviderStateMixin {
  final Account account;
  late TabController tabsController;

  BodyTabsState(this.account);

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
              Consumer(builder: (context, ref, w) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: account.tokens.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return TokenCard(account.tokens[index]);
                    },
                  ),
                );
              }),
              Consumer(builder: (context, ref, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: account.transactions.length,
                    itemBuilder: (context, index) {
                      final Transaction tx = account.transactions[index];
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

class HomeTabBody extends ConsumerStatefulWidget {
  HomeTabBody({Key? key, required this.account}) : super(key: key);

  final Account account;

  @override
  HomeTabBodyState createState() => HomeTabBodyState(this.account);
}

class HomeTabBodyState extends ConsumerState<HomeTabBody> {
  late Account account;

  HomeTabBodyState(this.account);

  @override
  Widget build(BuildContext context) {
    String solBalance = balanceShorter(account.balance.toString());
    String usdBalance = balanceShorter(account.usdBalance.toString());

    /*
     * If the SOL balance is 0.0 the USD equivalent will always be 0.0 too, so,
     * in order to prevent an infinite loading animation, it makes sure that the SOL balance is at least > 0.0, 
     * if not, it will just display 0.0
     */
    bool shouldRenderSpinner = account.balance > 0.0 && account.usdBalance == 0.0;

    // Convert the account's type to String
    String accountTypeText = "";
    if (account.accountType == AccountType.Client) {
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
                new ClipboardData(text: account.address),
              ).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Address copied to clipboard"),
                  ),
                );
              });
            },
            child: Text(
              '$accountTypeText (${account.address.substring(0, 5)}...)',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  solBalance,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
                const Text(' SOL'),
              ],
            ),
          ),
          if (shouldRenderSpinner) ...[
            Container(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                semanticsLabel: 'Loading SOL USD equivalent value',
              ),
            )
          ] else ...[
            Row(
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
            )
          ],
          if (account.accountType == AccountType.Wallet) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text("Send"),
                    onPressed: () {
                      WalletAccount walletAccount = account as WalletAccount;

                      sendTransactionDialog(context, walletAccount);
                    },
                  )
                ],
              ),
            )
          ] else ...[
            SizedBox(height: 15)
          ],
          BodyTabs(account)
        ],
      ),
    );
  }
}
