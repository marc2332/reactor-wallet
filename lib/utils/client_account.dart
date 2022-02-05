import 'package:reactor_wallet/utils/base_account.dart';
import 'package:solana/solana.dart' show SolanaClient;
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/tracker.dart';

/*
 * Address Client to watch over an specific address
 */
class ClientAccount extends BaseAccount implements Account {
  @override
  final AccountType accountType = AccountType.Client;

  ClientAccount(
    address,
    double balance,
    name,
    NetworkUrl url,
    TokenTrackers tokensTracker,
  ) : super(balance, name, url, tokensTracker) {
    this.address = address;
    client = SolanaClient(
      rpcUrl: Uri.parse(url.rpc),
      websocketUrl: Uri.parse(url.ws),
    );
  }

  @override
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
}
