import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/create_qr_transaction.dart';
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
        child: Consumer(builder: (context, ref, _) {
          List<Token> accountTokens = List.from(account.tokens);
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
        }),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isReady) ...[
            Text(
              solBalance,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
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
                    color: const Color.fromARGB(150, 0, 0, 0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}

class USDBalance extends StatelessWidget {
  final String usdBalance;
  final bool isReady;

  const USDBalance({Key? key, required this.usdBalance, required this.isReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$usdBalance\$',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        ],
      );
    } else {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 70,
          height: 35,
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }
  }
}

class AddressButton extends StatelessWidget {
  final Account account;
  final bool isReady;

  const AddressButton({
    Key? key,
    required this.account,
    required this.isReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      // Convert the account's type to String
      String accountTypeText = "";
      if (account.accountType == AccountType.Client) {
        accountTypeText = "Watcher";
      } else {
        accountTypeText = "Wallet";
      }

      return Row(
        children: [
          OutlinedButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: account.address),
              ).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Address copied to clipboard"),
                  ),
                );
              });
            },
            child: Text(
              '$accountTypeText (${account.address.substring(0, 5)}...)',
              style: Theme.of(context).textTheme.button,
            ),
          ),
          MaterialButton(
            height: 40,
            minWidth: 70,
            shape: const CircleBorder(),
            onPressed: () {
              createQRTransaction(context, account);
            },
            child: const Icon(Icons.qr_code_2_outlined),
          ),
        ],
      );
    } else {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 80,
          height: 20,
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SolBalance(
                    solBalance: solBalance,
                    isReady: account.isLoaded && account.isItemLoaded(AccountItem.solBalance),
                  ),
                  USDBalance(
                    usdBalance: usdBalance,
                    isReady: account.isLoaded && account.isItemLoaded(AccountItem.usdBalance),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AddressButton(
                      account: account,
                      isReady: account.isLoaded,
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
