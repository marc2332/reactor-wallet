import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/insufficient_funds.dart';
import 'package:reactor_wallet/dialogs/transaction_errored.dart';
import 'package:reactor_wallet/dialogs/transaction_sent.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:solana/solana.dart';
import 'package:worker_manager/worker_manager.dart';

Future<bool> makeTransactionWithLamports(
    WalletAccount account, String destination, int supply) async {
  try {
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> makeTransactionWithToken(
    WalletAccount account, String destination, String tokenMint, int supply) async {
  try {
    account.sendSPLTokenTo(destination, tokenMint, supply);

    return true;
  } catch (e) {
    return false;
  }
}

Future<void> prepareTransaction(
  BuildContext context,
  Transaction transaction,
  WalletAccount walletAccount,
  Token token,
) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return HookConsumer(
          builder: (context, ref, child) {
            final hasEnoughFunds = useState(false);

            TextStyle? fadedTextStyle = TextStyle(
              color: hasEnoughFunds.value ? null : Theme.of(context).fadedTextColor,
            );

            useEffect(() {
              AccountsManager manager = ref.read(accountsProvider.notifier);
              manager.refreshAccount(walletAccount.name).then((value) {
                if (transaction.programId == SystemProgram.programId) {
                  if (walletAccount.balance > transaction.ammount) {
                    hasEnoughFunds.value = true;
                  }
                } else {
                  walletAccount.tokens.forEach((token) {
                    if (token.balance >= transaction.ammount) {
                      hasEnoughFunds.value = true;
                    }
                  });
                }

                if (!hasEnoughFunds.value) {
                  Navigator.pop(context);
                  insuficientFundsDialog(context);
                }
              });
            }, []);

            return AlertDialog(
              title: const Text('Send this transaction?'),
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
                        '${transaction.ammount.toStringAsFixed(9)} ${token.info.symbol}',
                        style: fadedTextStyle,
                      ),
                      trailing: hasEnoughFunds.value
                          ? null
                          : CircularProgressIndicator(
                              strokeWidth: 3.0,
                              semanticsLabel: "Loading ${token.info.symbol} balance",
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
                  onPressed: hasEnoughFunds.value
                      ? () {
                          Navigator.of(context).pop();

                          // Show some feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sending ${transaction.ammount} ${token.info.symbol} to ${transaction.destination.substring(0, 5)}...',
                              ),
                            ),
                          );

                          try {
                            if (transaction.programId == SystemProgram.programId) {
                              // Convert SOL to lamport
                              int lamports = (transaction.ammount * 1000000000).toInt();
                              walletAccount.sendLamportsTo(transaction.destination, lamports);
                            } else {
                              int amount = transaction.ammount.toInt();
                              walletAccount.sendSPLTokenTo(
                                  transaction.destination, token.mint, amount);
                            }

                            // TODO: This should wait for the signature to be confirmed, and then show the "transactionHasBeenSentDialog"

                            // Display the "Transaction went OK" dialog
                            transactionHasBeenSentDialog(
                              context,
                              transaction.destination,
                              transaction.ammount,
                            );
                          } catch (_) {
                            // Display the "Transaction went wrong" dialog
                            transactionErroredDialog(
                              context,
                              transaction.destination,
                              transaction.ammount,
                            );
                          }
                        }
                      : null,
                ),
              ],
            );
          },
        );
      });
}
