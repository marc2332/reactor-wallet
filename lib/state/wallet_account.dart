import 'package:solana/solana.dart'
    show Ed25519HDKeyPair, RPCClient, RpcClient, SignedTx, SystemProgram, Wallet;
import 'package:solana_wallet/state/tracker.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'base_account.dart';
import 'package:encrypt/encrypt.dart';

// Master key to encrypt and decrypt mnemonics, aka passphrases
final secureKey = Key.fromUtf8(
    String.fromEnvironment("secureKey", defaultValue: "IthinkRustIsBetterLanguageThanJS"));
final iv = IV.fromLength(16);

class WalletAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(double balance, name, url, this.mnemonic, tokensTracker)
      : super(balance, name, url, tokensTracker) {
    client = RpcClient(url);
  }

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.withAddress(double balance, String address, name, url, this.mnemonic, tokensTracker)
      : super(balance, name, url, tokensTracker) {
    this.address = address;
    client = RpcClient(url);
  }

  /*
   *
   */

  void sendLamportsTo(String destinationAddress, int supply) async {
    final recentBlockhash = await client.getRecentBlockhash();

    final message = SystemProgram.transfer(
      source: address,
      destination: destinationAddress,
      lamports: supply,
    );

    final SignedTx signedTx = await wallet.signMessage(
      message: message,
      recentBlockhash: recentBlockhash.blockhash,
    );

    await client.sendTransaction(signedTx.encode());
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
    this.wallet = keyPair;
    this.address = wallet.address;
  }

  /*
   * Create a new WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(String name, String url, tokensTracker) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = new WalletAccount(0, name, url, randomMnemonic, tokensTracker);
    await account.loadKeyPair();
    await account.refreshBalance();
    return account;
  }

  static String decryptMnemonic(String mnemonic) {
    final encrypter = Encrypter(AES(secureKey));

    return encrypter.decrypt(Encrypted.fromBase64(mnemonic), iv: iv);
  }

  Map<String, dynamic> toJson() {
    final encrypter = Encrypter(AES(secureKey));

    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": url,
      "mnemonic": encrypter.encrypt(mnemonic, iv: iv).base64,
      "accountType": accountType.toString(),
      "transactions": transactions.map((tx) => tx.toJson()).toList()
    };
  }
}
