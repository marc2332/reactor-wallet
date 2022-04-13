import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class NetworkSelector extends HookConsumerWidget {
  final NetworkUrl customNetwork = NetworkUrl("", "");
  final Function(NetworkUrl?) onSelected;

  NetworkSelector({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = useState(urlOptions.keys.first);

    onSelected(urlOptions[selectedOption.value]);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: DropdownButton<String>(
            value: selectedOption.value,
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) {
              selectedOption.value = newValue!;
              if (selectedOption.value != 'Custom') {
                onSelected(urlOptions[selectedOption]);
              }
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
        if (selectedOption.value == 'Custom') ...[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Empty RPC URL';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter a custom RPC URL',
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
                  return 'Empty WebSockets URL';
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
