import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reactor_wallet/dialogs/insufficient_funds.dart';
import 'package:reactor_wallet/dialogs/make_transaction_manually.dart';
import 'package:reactor_wallet/dialogs/transaction_not_supported.dart';
import 'package:reactor_wallet/pages/scan_qr.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/solana_pay.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';

Future<void> selectTransactionMethod(
  BuildContext context,
  WalletAccount walletAccount,
) async {
  void solanaPaySelected() async {
    Barcode? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanQrPage()),
    );
    if (result != null) {
      String? uriSolanaPay = result.code;

      if (uriSolanaPay != null) {
        try {
          TransactionSolanaPay txData = TransactionSolanaPay.parseUri(uriSolanaPay);

          String defaultTokenSymbol = "SOL";

          if (txData.splToken != null) {
            try {
              Token selectedToken = walletAccount.getTokenByMint(txData.splToken!);
              defaultTokenSymbol = selectedToken.info.symbol;
            } catch (_) {
              insuficientFundsDialog(context);
              return;
            }
          }

          Navigator.pop(context);

          makePaymentManuallyDialog(
            context,
            walletAccount,
            initialDestination: txData.recipient,
            initialSendAmount: txData.amount ?? 0.0,
            defaultTokenSymbol: defaultTokenSymbol,
            references: txData.references,
          );
        } on FormatException {
          // Invalid URI
          paymentNotSupportedDialog(context);
        } catch (err) {
          paymentNotSupportedDialog(context);
        }
      } else {
        paymentNotSupportedDialog(context);
      }
    }
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select a method'),
        content: SizedBox(
          height: 200,
          child: Flex(
            direction: Axis.vertical,
            children: [
              if (!Platform.isWindows) ...[
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: solanaPaySelected,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 7),
                              child: Icon(Icons.qr_code_2_outlined),
                            ),
                            Text("Solana Pay QR"),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
              Expanded(
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      makePaymentManuallyDialog(context, walletAccount);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 7),
                            child: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          Text("Address"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
