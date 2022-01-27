import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/state/states.dart';

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(accountsProvider);

    ref.listen(appLoaded, (previous, bool next) {
      if (next) {
        final accountsLength = ref.read(accountsProvider.notifier).state.length;

        if (accountsLength > 0) {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, "/account_selection", (_) => false);
        }
      }
    });

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Opening your accounts 😄"),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Container(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    semanticsLabel: 'Loading SOL USD equivalent value',
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
