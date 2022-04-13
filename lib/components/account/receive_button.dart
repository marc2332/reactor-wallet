import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactor_wallet/dialogs/create_qr_payment.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveButton extends StatelessWidget {
  final Account account;
  final bool isReady;

  const ReceiveButton({
    Key? key,
    required this.account,
    required this.isReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: account.address),
                ).then(
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Address copied to clipboard"),
                      ),
                    );
                  },
                );
              },
              child: Text(
                'Share address',
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
          OutlinedButton(
            style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
            onPressed: () {
              createQRTransaction(context, account);
            },
            child: Row(
              children: [
                Text(
                  'Receive',
                  style: Theme.of(context).textTheme.button,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(Icons.qr_code_2_outlined, color: Theme.of(context).iconColor)),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 110,
              height: 30,
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 0, 0, 0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      );
    }
  }
}
