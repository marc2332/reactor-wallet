import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/account/info.dart';
import 'package:reactor_wallet/components/account/tokens.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';

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
