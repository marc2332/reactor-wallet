import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/token_card.dart';
import 'package:reactor_wallet/components/wrapper_image.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/state/providers.dart';

class TokenCardInfo extends ConsumerWidget {
  final Token token;

  const TokenCardInfo(this.token, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tokensTrackerProvider);

    String usdBalance = token.usdBalance.toStringAsFixed(2);
    String tokenBalance = token.balance.toStringAsFixed(2);

    return TokenCard(
      image: WrapperImage(token.info.logoUrl),
      title: Text(
        token.info.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(tokenBalance),
      tail: Text('\$$usdBalance'),
    );
  }
}
