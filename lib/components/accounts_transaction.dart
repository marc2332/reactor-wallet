import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/dialogs/transaction_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';

class UnsupportedTransactionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.block_outlined),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('Unsupported transaction'),
            )
          ],
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard(this.transaction);

  @override
  Widget build(BuildContext context) {
    bool toMe = transaction.receivedOrNot;
    String shortAddress =
        toMe ? transaction.origin.substring(0, 5) : transaction.destination.substring(0, 5);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          transactionInfo(context, transaction);
        },
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                toMe ? Icons.call_received_outlined : Icons.call_made_outlined,
                color: Theme.of(context).iconColor,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  '${toMe ? '+' : '-'}${transaction.ammount.toStringAsFixed(9)} SOL ${toMe ? 'from' : 'to'} $shortAddress...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountTransactions extends ConsumerStatefulWidget {
  AccountTransactions({Key? key, required this.account}) : super(key: key);

  final Account account;

  @override
  AccountTransactionsState createState() => AccountTransactionsState(this.account);
}

class AccountTransactionsState extends ConsumerState<AccountTransactions> {
  late Account account;

  AccountTransactionsState(this.account);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: RefreshIndicator(
          key: Key(account.address),
          onRefresh: () async {
            // Refresh the account when pulling down
            final accountsProv = ref.read(accountsProvider.notifier);
            await accountsProv.refreshAccount(account.name);
          },
          child: ListView.builder(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: account.transactions.length,
            itemBuilder: (context, index) {
              final Transaction tx = account.transactions[index];
              if (tx.origin != "Unknown") {
                return TransactionCard(tx);
              } else {
                return UnsupportedTransactionCard();
              }
            },
          ),
        ),
      ),
    );
  }
}
