import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/confirm_transaction.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:solana/solana.dart';

String? transactionAddressValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Empty address';
  }
  if (value.length < 43 || value.length > 50) {
    return 'Address length is not correct';
  } else {
    return null;
  }
}

Future<void> makePaymentManuallyDialog(
  BuildContext context,
  WalletAccount walletAccount, {
  String initialDestination = "",
  double initialSendAmount = 0,
  String defaultTokenSymbol = "SOL",
  List<String> references = const [],
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return HookConsumer(
        builder: (context, ref, _) {
          // Retrieve all the tokens owned by the account
          List<Token> tokens = List.from(walletAccount.tokens.values);

          // Add SOL (Solana) like if it was a Token just to make the UX easier
          tokens.insert(
            0,
            SOL(walletAccount.balance),
          );

          // Leave SOL as the default selection
          final selectedToken = useState(
            tokens.firstWhere(
              (token) => token.info.symbol == defaultTokenSymbol,
            ),
          );

          // Verify the amount sent
          String? transactionAmountValidator(String? value) {
            if (value == null || value.isEmpty) {
              return 'Empty ammount';
            }
            try {
              if (double.parse(value) <= 0) {
                return 'You must send at least 0.000000001 ${selectedToken.value.info.symbol}';
              } else {
                return null;
              }
            } on FormatException {
              return 'Invalid amount';
            }
          }

          final destination = useState(initialDestination);
          final sendAmount = useState(initialSendAmount);

          bool addressIsOk = transactionAddressValidator(destination.value) == null;
          bool amountIsOK = transactionAmountValidator(sendAmount.value.toString()) == null;

          Future<void> confirmTransaction() async {
            // Only let  it be sent if the address and the ammount is OK
            if (addressIsOk && amountIsOK) {
              // Close the dialog
              Navigator.of(dialogContext).pop();

              // Create transaction
              Transaction transaction = Transaction(
                walletAccount.address,
                destination.value,
                sendAmount.value,
                false,
                selectedToken.value.mint,
              );
              transaction.references = references;
              transaction.token = selectedToken.value;

              confirmTransactionDialog(
                context,
                transaction,
                walletAccount,
              );
            }
          }

          return AlertDialog(
            title: const Text('Transfer'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButton<String>(
                    iconSize: 20,
                    value: selectedToken.value.info.symbol,
                    icon: const Icon(Icons.arrow_downward),
                    underline: Container(),
                    onChanged: (String? tokenSymbol) {
                      if (tokenSymbol != null) {
                        selectedToken.value = tokens.firstWhere(
                          (token) => token.info.symbol == tokenSymbol,
                        );
                      }
                    },
                    items: tokens.map((Token token) {
                      return DropdownMenuItem<String>(
                        value: token.info.symbol,
                        child: Text(token.info.symbol + (token is NFT ? ' - NFT' : '')),
                      );
                    }).toList(),
                  ),
                  ListBody(
                    children: <Widget>[
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        child: TextFormField(
                          initialValue: initialDestination,
                          validator: transactionAddressValidator,
                          decoration: InputDecoration(
                            hintText: walletAccount.address,
                          ),
                          onChanged: (String value) async {
                            destination.value = value;
                          },
                        ),
                      ),
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        child: TextFormField(
                          initialValue: initialSendAmount.toString(),
                          validator: transactionAmountValidator,
                          decoration: const InputDecoration(
                            hintText: 'Amount',
                          ),
                          onChanged: (String value) async {
                            try {
                              sendAmount.value = double.parse(value);
                            } catch (_) {
                              // Do nothing on error
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Continue'),
                onPressed: addressIsOk && amountIsOK ? confirmTransaction : null,
              ),
            ],
          );
        },
      );
    },
  );
}
