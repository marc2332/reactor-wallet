import 'package:solana/solana.dart' show RPCClient, RpcClient;
import 'package:solana_wallet/state/tracker.dart';

import 'base_account.dart';

/*
 * Simple Address Client to watch over an specific address
 */
class ClientAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Client;

  ClientAccount(address, double balance, name, url, TokenTrackers tokensTracker)
      : super(balance, name, url, tokensTracker) {
    this.address = address;
    this.client = RpcClient(this.url);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": url,
      "accountType": accountType.toString(),
      "transactions": transactions.map((tx) => tx.toJson()).toList()
    };
  }

  static ClientAccount from(ClientAccount from) {
    return new ClientAccount(from.address, from.balance, from.name, from.url, from.tokensTracker);
  }
}
