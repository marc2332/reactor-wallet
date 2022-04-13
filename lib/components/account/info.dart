import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/account/account_home.dart';
import 'package:reactor_wallet/components/account/fiat_balance.dart';
import 'package:reactor_wallet/components/account/receive_button.dart';
import 'package:reactor_wallet/components/account/sol_balance.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/state/providers.dart';

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
                            child: FiatBalance(
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
