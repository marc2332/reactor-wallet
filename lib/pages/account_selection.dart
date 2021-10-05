import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../state/store.dart';

/*
 * Account Selection Page
 */
class AccountSelectionPage extends StatefulWidget {
  AccountSelectionPage({Key? key, required this.store}) : super(key: key);

  final store;

  @override
  AccountSelectionPageState createState() =>
      AccountSelectionPageState(this.store);
}

class AccountSelectionPageState extends State<AccountSelectionPage> {
  final store;

  AccountSelectionPageState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  child: InkWell(
                    splashColor: Theme.of(context).hoverColor,
                    onTap: () async {
                      Navigator.pushNamed(context, "/watch_address");
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text("Watch address (mainnet)")],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  child: InkWell(
                    splashColor: Theme.of(context).hoverColor,
                    onTap: () async {},
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text("Import wallet (not supported yet)")],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  child: InkWell(
                    splashColor: Theme.of(context).hoverColor,
                    onTap: () async {
                      Navigator.pushNamed(context, "/create_wallet");
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text("Create wallet (devnet for now)")],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
