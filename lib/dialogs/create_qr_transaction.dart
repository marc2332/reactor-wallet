import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reactor_wallet/components/numpad.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/solana_pay.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:solana/solana.dart' show SubscriptionClient, SystemProgram;

class ResponsiveRotator extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveRotator({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > 700)
      return Row(
        children: children,
      );
    else
      return Column(
        children: children,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
  }
}

List<TokenInfo> getAllPayableTokens(Account account) {
  List<TokenInfo> externalTokens = List.from(account.tokensTracker.tokensList.values.toList());
  List<TokenInfo> accountTokens = List.from(account.tokens)
      .where((token) => token is! NFT)
      .map<TokenInfo>((token) => token.info)
      .toList();

  externalTokens.removeWhere((info) => accountTokens.contains(info));
  //accountTokens.addAll(externalTokens);

  accountTokens.insert(0, TokenInfo.withInfo(SystemProgram.programId, "Solana", "", "SOL"));

  return accountTokens;
}

enum TransactionStatus { pending, loading, received }

Future<void> createQRTransaction(BuildContext context, Account account) async {
  List<TokenInfo> tokens = getAllPayableTokens(account);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return HookConsumer(
        builder: (context, ref, child) {
          final screenSize = MediaQuery.of(context).size;

          final amount = useState("0");
          final selectedToken = useState(tokens.first);
          final transactionData = useState<TransactionSolanaPay?>(null);
          final accountsManager = ref.read(accountsProvider.notifier);

          final transactionStatus = useState(TransactionStatus.pending);

          void generateQR() async {
            transactionData.value = TransactionSolanaPay(
              recipient: account.address,
              amount: double.parse(amount.value),
              splToken:
                  selectedToken.value.symbol != "SOL" ? selectedToken.value.mintAddress : null,
            );

            final client = SubscriptionClient(Uri.parse(account.url.ws));

            var stream;

            if (selectedToken.value.mintAddress == SystemProgram.programId) {
              stream = client.accountSubscribe(account.address);
            } else {
              final programAccount = await account.client.getAssociatedTokenAccount(
                owner: account.address,
                mint: selectedToken.value.mintAddress,
              );

              // Try to create a token account if there is none
              if (programAccount == null && account is WalletAccount) {
                await account.client.createAssociatedTokenAccount(
                  mint: selectedToken.value.mintAddress,
                  funder: account.wallet,
                  owner: account.address,
                );
              }

              stream = client.accountSubscribe(programAccount!.pubkey);
            }

            // TODO: Use reference to find the transaction and make sure the right amount / token was used
            stream.forEach((newAccount) {
              transactionStatus.value = TransactionStatus.loading;
              accountsManager.refreshAccount(account.name).then(
                    (value) => transactionStatus.value = TransactionStatus.received,
                  );
              client.close();
            });
          }

          void tapNumber(n) {
            // Remove the QR when the amount changes
            if (transactionData.value != null) {
              transactionData.value = null;
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

          void selectToken(TokenInfo? token) {
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
                ? const Text('Create transaction')
                : null,
            content: SingleChildScrollView(
              child: transactionStatus.value == TransactionStatus.pending
                  ? ResponsiveRotator(
                      children: [
                        Column(
                          children: [
                            DropdownButton<TokenInfo>(
                              value: selectedToken.value,
                              items: tokens
                                  .map<DropdownMenuItem<TokenInfo>>(
                                    (token) => DropdownMenuItem<TokenInfo>(
                                      child: Text(token.symbol),
                                      value: token,
                                    ),
                                  )
                                  .toList(),
                              onChanged: selectToken,
                            ),
                            screenSize.width > 700
                                ? Numpad(onPressed: tapNumber)
                                : SizedBox(
                                    width: 100,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) {
                                        amount.value = val;
                                      },
                                    ),
                                  )
                          ],
                        ),
                        Column(
                          children: [
                            Center(
                              child: Text(
                                amount.value.toString(),
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                            Padding(
                              padding: screenSize.width > 700
                                  ? const EdgeInsets.only(left: 50, right: 25)
                                  : EdgeInsets.zero,
                              child: SizedBox(
                                height: screenSize.width > 700 ? 250 : 150,
                                width: 250,
                                child: transactionData.value != null
                                    ? Center(
                                        child: QrImage(
                                            data: transactionData.value!.toUri(),
                                            version: QrVersions.auto),
                                      )
                                    : OutlinedButton(
                                        child: const Text("Create"),
                                        onPressed: generateQR,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : transactionStatus.value == TransactionStatus.loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                        )
                      : const Text("Received transaction!"),
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
