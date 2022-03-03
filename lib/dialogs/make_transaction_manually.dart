import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/confirm_transaction.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';

import '../components/account_home.dart';
import '../components/wrapper_image.dart';

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: SizedBox(
                          width: 200,
                          height: 90,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: WrapperImage(
                                    token.info.logoUrl,
                                    defaultIcon: Icons.credit_card_outlined,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(token.info.symbol.length > 10
                                        ? token.info.symbol.substring(0, 8)
                                        : token.info.symbol),
                                    if (token is! NFT) ...[
                                      Text(
                                        token is SOL
                                            ? "\$${balanceShorter(walletAccount.usdBalance.toString())}"
                                            : balanceShorter(token.usdBalance.toString()),
                                        style: const TextStyle(fontSize: 13),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                              Text(token is NFT ? "NFT" : balanceShorter(token.balance.toString()))
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ListBody(
                    children: <Widget>[
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: initialDestination,
                              validator: transactionAddressValidator,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                hintText: walletAccount.address,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 6, right: 5),
                                  child: Icon(Icons.account_box_rounded),
                                ),
                              ),
                              onChanged: (String value) async {
                                destination.value = value;
                              },
                            ),
                            TextFormField(
                              initialValue: initialSendAmount.toString(),
                              validator: transactionAmountValidator,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                hintText: "Amount",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(bottom: 6, right: 5),
                                  child: Icon(Icons.attach_money_outlined),
                                ),
                              ),
                              onChanged: (String value) async {
                                try {
                                  sendAmount.value = double.parse(value);
                                } catch (_) {
                                  // Do nothing on error
                                }
                              },
                            ),
                          ],
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
