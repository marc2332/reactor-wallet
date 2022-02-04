import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/wrapper_image.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';

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
                  padding: EdgeInsets.all(5),
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
