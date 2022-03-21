import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/accounts_transaction.dart';
import 'package:reactor_wallet/components/clickable_card.dart';
import 'package:reactor_wallet/dialogs/transaction_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionDetails transaction;

  const TransactionCard(this.transaction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool toMe = transaction.receivedOrNot;
    String shortAddress =
        toMe ? transaction.origin.substring(0, 5) : transaction.destination.substring(0, 5);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String readableDate = hourMinutFormatter.format(date);

    String transactionAmount = transaction.ammount.toString().contains("-")
        ? transaction.ammount.toStringAsFixed(9)
        : transaction.ammount.toString();

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(readableDate),
        ),
        Expanded(
          child: ClickableCard(
            onTap: () {
              paymentInfo(context, transaction);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    toMe ? Icons.call_received_outlined : Icons.call_made_outlined,
                    color: Theme.of(context).iconColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      '${toMe ? '+' : '-'} $transactionAmount SOL ${toMe ? 'from' : 'to'} $shortAddress...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
