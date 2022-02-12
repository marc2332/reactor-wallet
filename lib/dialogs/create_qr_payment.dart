import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reactor_wallet/components/numpad.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/solana_pay.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:solana/dto.dart' show Commitment;
import 'package:solana/solana.dart' show Ed25519HDKeyPair, SubscriptionClient;

class ResponsiveRotator extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveRotator({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > 700) {
      return Row(
        children: children,
      );
    } else {
      return Column(
        children: children,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }
  }
}

List<Token> getAllPayableTokens(Account account) {
  List<Token> accountTokens = List.from(account.tokens.values);
  accountTokens = accountTokens.where((token) => token is! NFT).toList();

  accountTokens.insert(0, SOL(account.balance));

  return accountTokens;
}

enum TransactionStatus {
  pending,
  received,
}

Future<void> createQRTransaction(BuildContext context, Account account) async {
  List<Token> tokens = getAllPayableTokens(account);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return HookConsumer(
        builder: (context, ref, child) {
          final screenSize = MediaQuery.of(context).size;

          final amount = useState("0");
          final selectedToken = useState(tokens.first);
          final transactionData = useState<TransactionSolanaPay?>(null);
          final errorMessage = useState<String?>(null);
          final accountsManager = ref.read(accountsProvider.notifier);

          final transactionStatus = useState(TransactionStatus.pending);

          void generateQR() async {
            final transactionIdentifier = await Ed25519HDKeyPair.random();
            var sendAmount = 0.0;

            try {
              sendAmount = double.parse(amount.value);
              if (sendAmount == 0) throw Exception();
            } catch (_) {
              errorMessage.value = "Invalid amount";
              return;
            }

            transactionData.value = TransactionSolanaPay(
              recipient: account.address,
              amount: sendAmount,
              splToken: selectedToken.value.info.symbol != "SOL" ? selectedToken.value.mint : null,
              references: [transactionIdentifier.address],
            );

            final client = SubscriptionClient(Uri.parse(account.url.ws));

            var stream;

            if (selectedToken.value is SOL) {
              stream = client.accountSubscribe(
                account.address,
                commitment: Commitment.confirmed,
              );
            } else {
              final programAccount = await account.client.getAssociatedTokenAccount(
                owner: account.address,
                mint: selectedToken.value.mint,
              );

              stream = client.accountSubscribe(
                programAccount!.pubkey,
                commitment: Commitment.confirmed,
              );
            }

            stream.forEach((newAccount) async {
              final sigs = await account.client.rpcClient.getSignaturesForAddress(
                transactionIdentifier.address,
                commitment: Commitment.confirmed,
              );

              if (sigs.isNotEmpty) {
                // TODO: Check amount of the transaction is correct
                transactionStatus.value = TransactionStatus.received;
              }
              accountsManager.refreshAccount(account.name);
              client.close();
            });
          }

          void tapNumber(n) {
            // Remove the QR when the amount changes
            if (transactionData.value != null) {
              transactionData.value = null;
            }

            // Remove any error when the amount changes
            if (errorMessage.value != null) {
              errorMessage.value = null;
            }

            String currentValue = amount.value;

            // Remove the last character
            if (n == "D") {
              if (currentValue.isNotEmpty) {
                amount.value = amount.value.substring(0, currentValue.length - 1);
              }
              return;
            }

            if (currentValue == "0" && n != ".") {
              // Replace the 0 with any number, but .
              amount.value = n;
            } else {
              // Append a number or .
              amount.value = '$currentValue$n';
            }
          }

          void selectToken(Token? token) {
            if (token != null) {
              selectedToken.value = token;
            }
            // Remove the QR when a token is selected
            if (transactionData.value != null) {
              transactionData.value = null;
            }
          }

          return AlertDialog(
            title: transactionStatus.value == TransactionStatus.pending
                ? const Text('Prepare transaction')
                : null,
            content: SingleChildScrollView(
              child: transactionStatus.value == TransactionStatus.pending
                  ? ResponsiveRotator(
                      children: [
                        Column(
                          children: [
                            DropdownButton<Token>(
                              value: selectedToken.value,
                              items: tokens
                                  .map(
                                    (token) => DropdownMenuItem<Token>(
                                      child: Text(token.info.symbol),
                                      value: token,
                                    ),
                                  )
                                  .toList(),
                              onChanged: selectToken,
                            ),
                            screenSize.width > 700
                                ? Numpad(onPressed: tapNumber)
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SizedBox(
                                      width: 100,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) {
                                          amount.value = val;
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        Column(
                          children: [
                            if (screenSize.width > 700) ...[
                              Center(
                                child: Text(
                                  amount.value.toString(),
                                  style: const TextStyle(fontSize: 40),
                                ),
                              )
                            ],
                            Padding(
                              padding: screenSize.width > 700
                                  ? const EdgeInsets.only(left: 25, right: 25, top: 15)
                                  : EdgeInsets.zero,
                              child: SizedBox(
                                height: screenSize.width > 700 ? 225 : 150,
                                width: 225,
                                child: transactionData.value != null
                                    ? Center(
                                        child: QrImage(
                                          data: transactionData.value!.toUri(),
                                          version: QrVersions.auto,
                                        ),
                                      )
                                    : OutlinedButton(
                                        child: const Text("Create"),
                                        onPressed: generateQR,
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: errorMessage.value != null
                                      ? [
                                          const Padding(
                                            padding: EdgeInsets.only(right: 7),
                                            child: Icon(Icons.error_outline_outlined),
                                          ),
                                          Text(errorMessage.value.toString())
                                        ]
                                      : [],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  : Padding(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Padding(
                            child: Icon(
                              Icons.verified_rounded,
                            ),
                            padding: EdgeInsets.only(right: 10),
                          ),
                          Text("Transaction received."),
                        ],
                      ),
                      padding: const EdgeInsets.only(top: 10),
                    ),
            ),
            actions: <Widget>[
              TextButton(
                child: transactionStatus.value == TransactionStatus.pending
                    ? const Text('Cancel')
                    : const Text('Dismiss'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              if (transactionStatus.value == TransactionStatus.pending) ...[
                TextButton(
                  child: const Text('Create'),
                  onPressed: generateQR,
                ),
              ]
            ],
          );
        },
      );
    },
  );
}
