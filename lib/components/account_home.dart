import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/states.dart';
import 'package:solana_wallet/state/tracker.dart';
import 'package:cached_network_image/cached_network_image.dart';

String balanceShorter(String balance) {
  if (balance.length >= 6) {
    balance = balance.substring(0, 6);
  }
  return balance;
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

    String usdBalance = token.usdBalance.toStringAsFixed(2);
    String tokenBalance = token.balance.toStringAsFixed(2);

    return Padding(
      padding: EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Theme.of(context).hoverColor,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: WrapperImage(tokenInfo.logoUrl),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tokenInfo.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(tokenBalance),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10), child: Text('$usdBalance\$'))
                  ],
                ),
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
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Padding(
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
          ),
          Expanded(
            flex: 3,
            child: Column(
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
          ),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 10,
                height: 20,
                decoration: BoxDecoration(
                  color: Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void orderTokensByUSDBalanace(List<Token> accountTokens) {
  accountTokens.sort((prev, next) {
    double prevBalanace = prev.usdBalance;
    double nextBalanace = next.usdBalance;

    return nextBalanace.compareTo(prevBalanace);
  });
}

class AccountTokens extends StatelessWidget {
  final Account account;

  AccountTokens(this.account);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Consumer(builder: (context, ref, _) {
            int accountTokenQuantity = account.tokens.length;
            List<Token> accountTokens = List.from(account.tokens);
            orderTokensByUSDBalanace(accountTokens);

            if (account.isItemLoaded(AccountItem.Tokens)) {
              if (accountTokenQuantity == 0) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: const Text("This address doesn't own any token"),
                          )
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: accountTokens.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return TokenCard(accountTokens[index]);
                  },
                );
              }
            } else {
              return ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return TokenCardWithShimmer();
                },
              );
            }
          })),
    );
  }
}

class AccountHome extends ConsumerStatefulWidget {
  AccountHome({Key? key, required this.account}) : super(key: key);

  final Account account;

  @override
  AccountHomeState createState() => AccountHomeState(this.account);
}

class AccountHomeState extends ConsumerState<AccountHome> {
  late Account account;

  AccountHomeState(this.account);

  @override
  Widget build(BuildContext context) {
    String solBalance = balanceShorter(account.balance.toString());
    String usdBalance = account.usdBalance.toStringAsFixed(2);

    // Convert the account's type to String
    String accountTypeText = "";
    if (account.accountType == AccountType.Client) {
      accountTypeText = "Watcher";
    } else {
      accountTypeText = "Wallet";
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RefreshIndicator(
                key: Key(account.address),
                onRefresh: () async {
                  // Refresh the account when pulling down
                  final accountsProv = ref.read(accountsProvider.notifier);
                  await accountsProv.refreshAccount(account.name);
                },
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (account.isLoaded &&
                                  account.isItemLoaded(AccountItem.SolBBalance)) ...[
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
                        if (account.isLoaded && account.isItemLoaded(AccountItem.USDBalance)) ...[
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
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: account.isLoaded
                              ? OutlinedButton(
                                  onPressed: () {
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
                                    style: Theme.of(context).textTheme.button,
                                  ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(flex: 2, child: AccountTokens(account)),
        ],
      ),
    );
  }
}
