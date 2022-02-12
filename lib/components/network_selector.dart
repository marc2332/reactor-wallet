import 'package:flutter/material.dart';

const options = [
  'Mainnet Beta (recommended)',
  'Devnet',
  'Testnet',
  'Custom',
];

var urlOptions = {
  'Mainnet Beta (recommended)':
      NetworkUrl('https://solana-api.projectserum.com', 'ws://solana-api.projectserum.com'),
  'Devnet': NetworkUrl('https://api.devnet.solana.com', 'ws://api.devnet.solana.com'),
  'Testnet': NetworkUrl('https://api.testnet.solana.com', 'ws://api.testnet.solana.com'),
  'Custom': NetworkUrl('', ''),
};

class NetworkUrl {
  late String rpc;
  late String ws;
  NetworkUrl(this.rpc, this.ws);
}

class NetworkSelector extends StatefulWidget {
  final Function(NetworkUrl?) onSelected;

  const NetworkSelector({Key? key, required this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NetworkSelectorState(onSelected);
}

class NetworkSelectorState extends State<NetworkSelector> {
  String selectedOption = urlOptions.keys.first;
  NetworkUrl customNetwork = NetworkUrl("", "");
  Function(NetworkUrl?) onSelected;

  NetworkSelectorState(this.onSelected);

  @override
  Widget build(BuildContext context) {
    onSelected(urlOptions[selectedOption]);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: DropdownButton<String>(
            value: selectedOption,
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                selectedOption = newValue!;
                if (selectedOption != 'Custom') {
                  onSelected(urlOptions[selectedOption]);
                }
              });
            },
            items: options.map<DropdownMenuItem<String>>(
              (String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              },
            ).toList(),
          ),
        ),
        if (selectedOption == 'Custom') ...[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Empty URL';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter a custom network URL',
              ),
              onChanged: (String value) async {
                customNetwork.rpc = value;
                onSelected(customNetwork);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Empty URL';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter a custom WebSockets URL',
              ),
              onChanged: (String value) async {
                customNetwork.ws = value;
                onSelected(customNetwork);
              },
            ),
          )
        ]
      ],
    );
  }
}
