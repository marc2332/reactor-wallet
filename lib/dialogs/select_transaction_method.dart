import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reactor_wallet/dialogs/insufficient_funds.dart';
import 'package:reactor_wallet/dialogs/prepare_transaction.dart';
import 'package:reactor_wallet/dialogs/send_transaction_by_address.dart';
import 'package:reactor_wallet/dialogs/transaction_not_suported.dart';
import 'package:reactor_wallet/pages/scan_qr.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/solana_pay.dart';
import 'package:reactor_wallet/utils/tracker.dart';
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
          TransactionSolanaPay txData = parseUri(uriSolanaPay);

          if (txData.splToken == null) {
            Transaction tx = Transaction(
              walletAccount.address,
              txData.recipient,
              txData.amount,
              false,
              system_program_id,
            );

            Navigator.pop(context);

            prepareTransaction(
              context,
              tx,
              walletAccount,
              Token(walletAccount.balance, system_program_id, "SOL"),
            );
          } else {
            Transaction tx = Transaction(
              walletAccount.address,
              txData.recipient,
              txData.amount,
              false,
              token_program_id,
            );

            Navigator.pop(context);

            tx.tokenMint = txData.splToken!;

            Token ownedToken;

            try {
              ownedToken = walletAccount.getTokenByMint(tx.tokenMint);
            } catch (_) {
              insuficientFundsDialog(context);
              return;
            }

            prepareTransaction(
              context,
              tx,
              walletAccount,
              ownedToken,
            );
          }
        } on FormatException {
          // Invalid URI
          transactionNotSupportedDialog(context);
        } catch (err) {
          transactionNotSupportedDialog(context);
        }
      } else {
        transactionNotSupportedDialog(context);
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
                      sendTransactionDialog(context, walletAccount);
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
