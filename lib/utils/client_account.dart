import 'package:solana/solana.dart' show SolanaClient;
import 'package:solana_wallet/components/network_selector.dart';
import 'package:solana_wallet/utils/tracker.dart';

import 'base_account.dart';

/*
 * Simple Address Client to watch over an specific address
 */
class ClientAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Client;

  ClientAccount(
    address,
    double balance,
    name,
    NetworkUrl url,
    TokenTrackers tokensTracker,
  ) : super(
          balance,
          name,
          url,
          tokensTracker,
        ) {
    this.address = address;
    this.client = SolanaClient(rpcUrl: Uri.parse(url.rpc), websocketUrl: Uri.parse(url.ws));
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": [url.rpc, url.ws],
      "accountType": accountType.toString(),
      "transactions": transactions.map((tx) => tx.toJson()).toList()
    };
  }

  static ClientAccount from(ClientAccount from) {
    return new ClientAccount(from.address, from.balance, from.name, from.url, from.tokensTracker);
  }
}
