import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:reactor_wallet/components/token_card.dart';
import 'package:reactor_wallet/components/token_card_shimmer.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';

String balanceShorter(String balance) {
  if (balance.length >= 6) {
    balance = balance.substring(0, 6);
  }
  return balance;
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
  final ScrollController list_controller = ScrollController();

  AccountTokens(this.account);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                          padding: const EdgeInsets.only(top: 20),
                          child: const Text("This address doesn't own any token"),
                        )
                      ],
                    )
                  ],
                ),
              );
            } else {
              return ListView.builder(
                controller: list_controller,
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
              controller: list_controller,
              itemCount: 7,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TokenCardWithShimmer();
              },
            );
          }
        }),
      ),
    );
  }
}

class AccountInfo extends ConsumerWidget {
  final Account account;

  AccountInfo(this.account);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String solBalance = balanceShorter(account.balance.toString());
    String usdBalance = account.usdBalance.toStringAsFixed(2);

    // Convert the account's type to String
    String accountTypeText = "";
    if (account.accountType == AccountType.Client) {
      accountTypeText = "Watcher";
    } else {
      accountTypeText = "Wallet";
    }

    return Row(
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
                    padding: const EdgeInsets.only(bottom: 10, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (account.isLoaded && account.isItemLoaded(AccountItem.SolBBalance)) ...[
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 90,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(150, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          )
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
                    padding: const EdgeInsets.only(top: 10),
                    child: account.isLoaded
                        ? OutlinedButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: account.address),
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
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AccountInfo(account),
          Expanded(flex: 2, child: AccountTokens(account)),
        ],
      ),
    );
  }
}
