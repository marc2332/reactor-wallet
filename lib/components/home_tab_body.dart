import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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

class TokenCardWithShimmer extends StatelessWidget {
  const TokenCardWithShimmer();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Theme.of(context).hoverColor,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(150, 0, 0, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 65,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: SizedBox()),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 20,
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

  BodyTabsState(this.account);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TabBar(
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
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Container(
                height: 320,
                child: TabBarView(
                  children: <Widget>[
                    Consumer(builder: (context, ref, _) {
                      int accountTokenQuantity = account.tokens.length;

                      if (account.isItemLoaded(AccountItem.Tokens)) {
                        if (accountTokenQuantity == 0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: const Text("This address doesn't own any token"),
                                  )
                                ],
                              )
                            ],
                          );
                        } else {
                          return ListView.builder(
                            itemCount: account.tokens.length,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return TokenCard(account.tokens[index]);
                            },
                          );
                        }
                      } else {
                        return ListView.builder(
                          itemCount: 5,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return TokenCardWithShimmer();
                          },
                        );
                      }
                    }),
                    Consumer(builder: (context, ref, _) {
                      return ListView.builder(
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
                      );
                    })
                  ],
                ),
              )),
        ],
      ),
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
    bool loadedUsdBalance = !(account.balance > 0.0 && account.usdBalance == 0.0);

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
            child: account.isLoaded
                ? Text(
                    '$accountTypeText (${account.address.substring(0, 5)}...)',
                    style: TextStyle(color: Colors.black),
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (account.isLoaded) ...[
                  Text(
                    solBalance,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const Text(' SOL'),
                ] else ...[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (account.isLoaded && loadedUsdBalance) ...[
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
          ] else ...[
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  color: Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
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
