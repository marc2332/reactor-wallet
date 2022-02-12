import 'package:solana/dto.dart' show Commitment, ProgramAccount;
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart'
    show
        Ed25519HDKeyPair,
        NoAssociatedTokenAccountException,
        RpcClientExt,
        SolanaClient,
        SystemInstruction,
        TokenProgram,
        Wallet,
        lamportsPerSol,
        signTransaction;
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'base_account.dart';
import 'package:encrypt/encrypt.dart';

// Master key to encrypt and decrypt mnemonics, aka passphrases, this is included when creating the build
final secureKey = Key.fromUtf8(
  // ignore: prefer_const_constructors
  String.fromEnvironment("secureKey", defaultValue: "IthinkRustIsBetterLanguageThanJS"),
);
final iv = IV.fromLength(16);

class WalletAccount extends BaseAccount implements Account {
  @override
  final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(
    double balance,
    name,
    NetworkUrl url,
    this.mnemonic,
    tokensTracker,
  ) : super(balance, name, url, tokensTracker) {
    client = SolanaClient(
      rpcUrl: Uri.parse(url.rpc),
      websocketUrl: Uri.parse(url.ws),
    );
  }

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.withAddress(
    double balance,
    String address,
    name,
    NetworkUrl url,
    this.mnemonic,
    tokensTracker,
  ) : super(balance, name, url, tokensTracker) {
    this.address = address;
    client = SolanaClient(
      rpcUrl: Uri.parse(url.rpc),
      websocketUrl: Uri.parse(url.ws),
    );
  }

  /*
   * Send SOLs to an adress
   */
  Future<String> sendLamportsTo(
    String destinationAddress,
    int amount, {
    List<String> references = const [],
  }) async {
    final instruction = SystemInstruction.transfer(
      source: address,
      destination: destinationAddress,
      lamports: amount,
    );

    for (final reference in references) {
      instruction.accounts.add(
        AccountMeta(
          pubKey: reference,
          isWriteable: false,
          isSigner: false,
        ),
      );
    }

    final message = Message(
      instructions: [instruction],
    );

    final signature = await client.rpcClient.signAndSendTransaction(message, [wallet]);

    return signature;
  }

  /*
   * Send a Token to an adress
   */
  Future<String> sendSPLTokenTo(
    String destinationAddress,
    String tokenMint,
    int amount, {
    List<String> references = const [],
  }) async {
    final associatedRecipientAccount = await client.getAssociatedTokenAccount(
      owner: destinationAddress,
      mint: tokenMint,
    );

    final associatedSenderAccount = await client.getAssociatedTokenAccount(
      owner: address,
      mint: tokenMint,
    ) as ProgramAccount;

    final message = TokenProgram.transfer(
      source: associatedSenderAccount.pubkey,
      destination: associatedRecipientAccount!.pubkey,
      amount: amount,
      owner: address,
    );

    for (final reference in references) {
      message.instructions.first.accounts.add(
        AccountMeta(
          pubKey: reference,
          isWriteable: false,
          isSigner: false,
        ),
      );
    }

    final signature = await client.rpcClient.signAndSendTransaction(message, [wallet]);

    return signature;
  }

  Future<String> sendTransaction(Transaction transaction) {
    if (transaction.token is SOL) {
      // Convert SOL to lamport
      int lamports = (transaction.ammount * lamportsPerSol).toInt();

      return sendLamportsTo(
        transaction.destination,
        lamports,
        references: transaction.references,
      );
    } else {
      // Input by the user
      int userAmount = transaction.ammount.toInt();
      // Token's configured decimals
      int tokenDecimals = transaction.token.info.decimals;
      int amount = int.parse('$userAmount${'0' * tokenDecimals}');

      return sendSPLTokenTo(
        transaction.destination,
        transaction.token.mint,
        amount,
        references: transaction.references,
      );
    }
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
    final Ed25519HDKeyPair keyPair = await Executor().execute(
      arg1: mnemonic,
      fun1: createKeyPair,
    );
    wallet = keyPair;
    address = wallet.address;
  }

  /*
   * Create a WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(String name, NetworkUrl url, tokensTracker) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = WalletAccount(
      0,
      name,
      url,
      randomMnemonic,
      tokensTracker,
    );
    await account.loadKeyPair();
    await account.refreshBalance();
    return account;
  }

  /*
   * Decrypt the mnemonic using the master key
   */
  static String decryptMnemonic(String mnemonic) {
    final encrypter = Encrypter(AES(secureKey));

    return encrypter.decrypt(
      Encrypted.fromBase64(mnemonic),
      iv: iv,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final encrypter = Encrypter(AES(secureKey));

    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": [url.rpc, url.ws],
      "mnemonic": encrypter.encrypt(mnemonic, iv: iv).base64,
      "accountType": accountType.toString(),
      "transactions": transactions.map((tx) => tx.toJson()).toList()
    };
  }
}
