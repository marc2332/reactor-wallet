import 'package:solana/solana.dart' show Ed25519HDKeyPair, RPCClient, Wallet;
import 'package:solana_wallet/state/store.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'base_account.dart';

class WalletAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(double balance, name, url, this.mnemonic, valuesTracker)
      : super(balance, name, url, valuesTracker) {
    client = RPCClient(url);
  }

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.withAddress(double balance, String address, name, url, this.mnemonic, valuesTracker)
      : super(balance, name, url, valuesTracker) {
    this.address = address;
    client = RPCClient(url);
  }

  /*
   * Create the keys pair in Isolate to prevent blocking the main thread
   */
  static Future<Ed25519HDKeyPair> createKeyPair(String mnemonic) async {
    final Ed25519HDKeyPair keyPair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    return keyPair;
  }

  /*
   * Load the keys pair into the WalletAccount
   */
  Future<void> loadKeyPair() async {
    final Ed25519HDKeyPair keyPair = await Executor().execute(arg1: mnemonic, fun1: createKeyPair);
    final Wallet wallet = new Wallet(signer: keyPair, rpcClient: client);
    this.wallet = wallet;
    this.address = wallet.address;
  }

  /*
   * Create a new WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(String name, String url, valuesTracker) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = new WalletAccount(0, name, url, randomMnemonic, valuesTracker);
    await account.loadKeyPair();
    await account.refreshBalance();
    return account;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": url,
      "mnemonic": mnemonic,
      "accountType": accountType.toString(),
      "transactions": transactions.map((tx) => tx.toJson())
    };
  }
}
