import 'package:flutter/material.dart';
import '../state/store.dart';

/*
 * Account Selection Page
 */
class AccountSelectionPage extends StatelessWidget {
  AccountSelectionPage({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account selection"),
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
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.person_pin_outlined,
                            size: 30.0,
                          ),
                        ),
                        const Text("Watch address"),
                      ],
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
                      Navigator.pushNamed(context, "/import_wallet");
                    },
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.import_export_outlined,
                            size: 30.0,
                          ),
                        ),
                        const Text("Import wallet"),
                      ],
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
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.create_outlined,
                            size: 30.0,
                          ),
                        ),
                        const Text("Create wallet"),
                      ],
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
