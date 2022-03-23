import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/clickable_card.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/pages/create_wallet.dart';
import 'package:reactor_wallet/pages/import_wallet.dart';
import 'package:reactor_wallet/pages/watch_address.dart';

/*
 * Account Selection Page
 */
class AccountSelectionPage extends StatelessWidget {
  const AccountSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account selection"),
      ),
      body: ResponsiveSizer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 1,
                  child: ClickableCard(
                    onTap: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return const ImportWallet();
                          },
                        ),
                      );
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.import_export_outlined,
                            size: 30.0,
                          ),
                        ),
                        Text("Import wallet"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ClickableCard(
                    onTap: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return const CreateWallet();
                          },
                        ),
                      );
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.create_outlined,
                            size: 30.0,
                          ),
                        ),
                        Text("Create wallet"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ClickableCard(
                    onTap: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return const WatchAddress();
                          },
                        ),
                      );
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.person_pin_outlined,
                            size: 30.0,
                          ),
                        ),
                        Text("Watch address"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
