import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/insufficient_funds.dart';
import 'package:reactor_wallet/dialogs/transaction_error.dart';
import 'package:reactor_wallet/dialogs/transaction_sent.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';

/*
 * Ask the user to confirm the transactio
 */
Future<void> confirmTransactionDialog(
  BuildContext context,
  Transaction transaction,
  WalletAccount walletAccount,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return HookConsumer(
        builder: (context, ref, child) {
          Future<void> sendTransaction() async {
            Navigator.of(context).pop();

            try {
              // Send the transaction and pass the callback (future) to the next dialog
              final future = walletAccount.sendTransaction(transaction);

              transactionIsBeingConfirmedDialog(
                context,
                future,
                transaction,
                transaction.token.info,
                walletAccount,
              );
            } catch (_) {
              // Display the "Transaction went wrong" dialog
              paymentErrorDialog(
                context,
                transaction.destination,
                transaction.ammount,
              );
            }
          }

          final hasEnoughFunds = useState(false);

          TextStyle? fadedTextStyle = TextStyle(
            color: hasEnoughFunds.value ? null : Theme.of(context).fadedTextColor,
          );

          useEffect(() {
            AccountsManager manager = ref.read(accountsProvider.notifier);
            manager.refreshAccount(walletAccount.name).then((value) {
              if (transaction.token is SOL) {
                // Check if the SOL balance is enough
                if (walletAccount.balance > transaction.ammount) {
                  hasEnoughFunds.value = true;
                }
              } else {
                // Find the owned token and make sure the balance is enough
                Token? token = walletAccount.tokens[transaction.token.mint];
                if (token != null && token.balance > transaction.ammount) {
                  hasEnoughFunds.value = true;
                }
              }

              // Show an error if funds are not enough
              if (!hasEnoughFunds.value) {
                Navigator.pop(context);
                insuficientFundsDialog(context);
              }
            });
          }, []);

          return AlertDialog(
            title: const Text('Confirm transaction'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    title: const Text('From'),
                    subtitle: Text(transaction.origin),
                  ),
                  ListTile(
                    title: Text('Amount', style: fadedTextStyle),
                    subtitle: Text(
                      '${transaction.ammount.toStringAsFixed(9)} ${transaction.token.info.symbol}',
                      style: fadedTextStyle,
                    ),
                    trailing: hasEnoughFunds.value
                        ? null
                        : CircularProgressIndicator(
                            strokeWidth: 3.0,
                            semanticsLabel: "Loading ${transaction.token.info.symbol} balance",
                          ),
                  ),
                  ListTile(
                    title: const Text('Send to'),
                    subtitle: Text(transaction.destination),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Send'),
                onPressed: hasEnoughFunds.value ? sendTransaction : null,
              ),
            ],
          );
        },
      );
    },
  );
}
