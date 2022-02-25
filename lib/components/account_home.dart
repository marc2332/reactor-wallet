import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/create_qr_payment.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:reactor_wallet/components/token_card.dart';
import 'package:reactor_wallet/components/token_card_shimmer.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';

String balanceShorter(String balance) {
  if (balance.length >= 6) {
    balance = balance.substring(0, 6);
  }
  return balance;
}

/*
 * Sort the tokens from more valuable to less valuable
 */
void orderTokensByUSDBalanace(List<Token> accountTokens) {
  accountTokens.sort((prev, next) {
    double prevBalanace = prev.usdBalance;
    double nextBalanace = next.usdBalance;

    return nextBalanace.compareTo(prevBalanace);
  });
}

class AccountTokens extends StatelessWidget {
  final Account account;
  final ScrollController listController = ScrollController();

  AccountTokens(this.account, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            List<Token> accountTokens = List.from(account.tokens.values);
            accountTokens.retainWhere((token) => token is! NFT);

            int accountTokenQuantity = accountTokens.length;

            orderTokensByUSDBalanace(accountTokens);

            if (account.isItemLoaded(AccountItem.tokens)) {
              if (accountTokenQuantity == 0) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text("This address doesn't own any token"),
                          )
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  controller: listController,
                  itemCount: accountTokens.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return TokenCard(accountTokens[index]);
                  },
                );
              }
            } else {
              return ListView.builder(
                controller: listController,
                itemCount: 7,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return const TokenCardWithShimmer();
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class SolBalance extends StatelessWidget {
  final String solBalance;
  final bool isReady;

  const SolBalance({Key? key, required this.solBalance, required this.isReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Row(
        children: [
          Text(
            solBalance,
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '  SOL',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 110,
            height: 30,
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 0, 0, 0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    }
  }
}

class USDBalance extends StatelessWidget {
  final String usdBalance;
  final bool isReady;

  const USDBalance({Key? key, required this.usdBalance, required this.isReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Text('\$$usdBalance',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 33,
            ),
          ),
          textAlign: TextAlign.left);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 0, 0, 0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }
  }
}

class ReceiveButton extends StatelessWidget {
  final Account account;
  final bool isReady;

  const ReceiveButton({
    Key? key,
    required this.account,
    required this.isReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: account.address),
                ).then(
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Address copied to clipboard"),
                      ),
                    );
                  },
                );
              },
              child: Text(
                'Share address',
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
          OutlinedButton(
            style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
            onPressed: () {
              createQRTransaction(context, account);
            },
            child: Row(
              children: [
                Text(
                  'Receive',
                  style: Theme.of(context).textTheme.button,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(Icons.qr_code_2_outlined, color: Theme.of(context).iconColor)),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 110,
              height: 30,
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 0, 0, 0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class AccountInfo extends ConsumerWidget {
  final Account account;

  const AccountInfo(this.account, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String solBalance = balanceShorter(account.balance.toString());
    String usdBalance = account.usdBalance.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
      ),
      child: RefreshIndicator(
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
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 15),
                            child: USDBalance(
                              usdBalance: usdBalance,
                              isReady:
                                  account.isLoaded && account.isItemLoaded(AccountItem.usdBalance),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, bottom: 20, top: 15),
                            child: SolBalance(
                              solBalance: solBalance,
                              isReady:
                                  account.isLoaded && account.isItemLoaded(AccountItem.solBalance),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ReceiveButton(
                        account: account,
                        isReady: account.isLoaded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccountHome extends StatelessWidget {
  final Account account;

  const AccountHome({Key? key, required this.account}) : super(key: key);

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
