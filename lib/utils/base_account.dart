import 'dart:async';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:solana/metaplex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageInfo {
  final String uri;
  final OffChainMetadata? data;

  const ImageInfo(this.uri, this.data);
}

Future<ImageInfo?> getImageFromUri(String uri) async {
  try {
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';
    http.Response response = await http.get(
      Uri.parse(uri),
      headers: headers,
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    final sanitizedUri = body["image"];

    OffChainMetadata? data;

    try {
      data = OffChainMetadata.fromJson(body);
    } catch (err) {
      data = null;
    }
    return ImageInfo(sanitizedUri, data);
  } catch (err) {
    return null;
  }
}

class Token {
  // How much of this token
  late double balance = 0;
  // USD equivalent of the balance
  late double usdBalance = 0;
  // Mint of this token
  final String mint;
  // Info about the token
  final TokenInfo info;

  Token(this.balance, this.mint, this.info);
}

class NFT extends Token {
  final ImageInfo? imageInfo;

  NFT(
    double balance,
    String mint,
    TokenInfo info,
    this.imageInfo,
  ) : super(balance, mint, info);
}

class SOL extends Token {
  SOL(
    double balance,
  ) : super(balance, "", TokenInfo(name: "Solana", symbol: "SOL"));
}

enum AccountItem {
  tokens,
  usdBalance,
  solBalance,
  transactions,
}

class BaseAccount {
  final NetworkUrl url;
  late String name;
  late bool isLoaded = true;
  late SolanaClient client;
  late String address;
  late double balance = 0;
  late double usdBalance = 0;
  late TokenTrackers tokensTracker;
  late List<TransactionDetails> transactions = [];
  late Map<String, Token> tokens = {};
  final itemsLoaded = <AccountItem, bool>{};

  BaseAccount(this.balance, this.name, this.url, this.tokensTracker);

  /*
   * Determine if an item of this account, e.g, if token are loaded
   */
  bool isItemLoaded(AccountItem item) {
    return itemsLoaded[item] != null;
  }

  /*
   * Get a token by it's mint address
   */
  Token getTokenByMint(String mint) {
    return tokens[mint] as Token;
  }

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.rpcClient.getBalance(address, commitment: Commitment.confirmed);

    this.balance = balance.toDouble() / lamportsPerSol;
    itemsLoaded[AccountItem.solBalance] = true;

    usdBalance = this.balance * tokensTracker.getTokenValue(SystemProgram.programId);

    itemsLoaded[AccountItem.usdBalance] = true;

    for (final token in tokens.values) {
      updateUsdFromTokenValue(token);
    }
  }

  /*
   * Sum a token value into the account's global USD balance
   */
  void updateUsdFromTokenValue(Token token) {
    try {
      Tracker? tracker = tokensTracker.getTracker(token.mint);
      if (tracker != null) {
        double tokenUsdBalance = (token.balance * tracker.usdValue);
        token.usdBalance = tokenUsdBalance;
        usdBalance += tokenUsdBalance;
      }
      // ignore: empty_catches
    } catch (err) {}
  }

  /*
   * Loads all the tokens (spl-program mints) owned by this account
   */
  Future<void> loadTokens() async {
    final completer = Completer();

    // Get all the tokens owned by the account
    final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilter.byProgramId(TokenProgram.programId),
      commitment: Commitment.confirmed,
      encoding: Encoding.jsonParsed,
    );

    int notOwnedNFTs = 0;

    tokenAccounts.asMap().forEach(
      (index, tokenAccount) {
        ParsedAccountData? data = tokenAccount.account.data as ParsedAccountData?;

        if (data != null) {
          data.when(
            splToken: (data) {
              data.when(
                  account: (mintData, type, accountType) {
                    String tokenMint = mintData.mint;
                    int decimals = mintData.tokenAmount.decimals;
                    String? uiBalance = mintData.tokenAmount.uiAmountString;
                    double balance = double.parse(uiBalance ?? "0");

                    String defaultName = "Unknown $index";
                    TokenInfo defaultTokenInfo = TokenInfo(
                      name: defaultName,
                      symbol: defaultName,
                      decimals: decimals,
                    );

                    // Start tracking the token
                    TokenInfo tokenInfo = tokensTracker.addTrackerByProgramMint(
                      tokenMint,
                      defaultValue: defaultTokenInfo,
                    );

                    // Add the token to this account
                    client.rpcClient.getMetadata(mint: tokenMint).then(
                      (value) async {
                        try {
                          ImageInfo imageInfo = await getImageFromUri(value!.uri) as ImageInfo;
                          if (balance > 0) {
                            tokens[tokenMint] = NFT(balance, tokenMint, tokenInfo, imageInfo);
                          } else {
                            notOwnedNFTs++;
                          }
                        } catch (_) {
                          tokens[tokenMint] = Token(balance, tokenMint, tokenInfo);
                        } finally {
                          if (tokens.length + notOwnedNFTs == tokenAccounts.length) {
                            itemsLoaded[AccountItem.tokens] = true;
                            try {
                              completer.complete();
                            } catch (_) {}
                          }
                        }
                      },
                    );
                  },
                  mint: (_, __, ___) {},
                  unknown: (_) {});
            },
            unsupported: (_) {},
            stake: (_) {},
          );
        }
      },
    );

    if (tokenAccounts.isEmpty) {
      itemsLoaded[AccountItem.tokens] = true;
      completer.complete();
    }

    return completer.future;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    transactions = [];

    try {
      final response = await client.rpcClient.getTransactionsList(
        address,
        commitment: Commitment.confirmed,
      );

      for (final tx in response) {
        final message = tx.transaction.message;

        for (final instruction in message.instructions) {
          if (instruction is ParsedInstruction) {
            instruction.map(
              system: (data) {
                data.parsed.map(
                  transfer: (data) {
                    ParsedSystemTransferInformation transfer = data.info;
                    bool receivedOrNot = transfer.destination == address;
                    double ammount = transfer.lamports.toDouble() / lamportsPerSol;

                    transactions.add(
                      TransactionDetails(
                        transfer.source,
                        transfer.destination,
                        ammount,
                        receivedOrNot,
                        SystemProgram.programId,
                        tx.blockTime!,
                      ),
                    );
                  },
                  transferChecked: (_) {},
                  unsupported: (_) {
                    transactions.add(UnsupportedTransaction(tx.blockTime!));
                  },
                );
              },
              splToken: (data) {
                data.parsed.map(
                  transfer: (data) {},
                  transferChecked: (data) {},
                  generic: (data) {},
                );
              },
              memo: (_) {},
              unsupported: (a) {
                transactions.add(UnsupportedTransaction(tx.blockTime!));
              },
            );
          }
        }
      }
    } catch (err) {}

    itemsLoaded[AccountItem.transactions] = true;
  }
}

/*
 * WalletAccount and ClientAccount implement this
 */
abstract class Account {
  // Account's Type, e.g, Watcher or Wallet
  final AccountType accountType;
  // Account's name
  late String name;
  // Account network configuration, aka json rpc / websockets node
  final NetworkUrl url;
  // Account's client to the the configured node
  late SolanaClient client;
  // SOL balance
  late double balance = 0;
  // USD balance of SOL and all the tokens combined
  late double usdBalance = 0;
  // Account's address
  late String address;
  // A tokens tracker used to share token information like USD equivalent values across all the user's accounts, this makes prevent making the same request multiple times, e.g
  // If two accounts own the same token, fetching the USD value of that token will only be made once.
  late TokenTrackers tokensTracker;
  // Recent transactions
  late List<TransactionDetails> transactions = [];
  // Tokens owned by this account
  late Map<String, Token> tokens = {};

  // Flag used only to easily create an account with shimmer effects on the Home page
  late bool isLoaded = true;

  Account(this.accountType, this.name, this.url);

  // Know if an account item is loaded, e.g, tokens or transactions
  bool isItemLoaded(AccountItem item);
  // Increase the USD value of the account when a new token is added
  void updateUsdFromTokenValue(Token token);
  // Fetch the SOL balance
  Future<void> refreshBalance();
  // Fetch the latest transactions
  Future<void> loadTransactions();
  // Fetch the owned tokens
  Future<void> loadTokens();

  // Convert the account data into JSON
  Map<String, dynamic> toJson();
}

class TransactionDetails {
  // Who sent the transaction
  final String origin;
  // Recipient of the transaction
  final String destination;
  // How much
  final double ammount;
  // Was the account of this transaction the same as the destination
  final bool receivedOrNot;
  // The Program ID of this transaction, e.g, System Program, Token Program...
  final String programId;
  // The UNIX timestamp of the block where the transaction was included
  final int blockTime;

  TransactionDetails(
    this.origin,
    this.destination,
    this.ammount,
    this.receivedOrNot,
    this.programId,
    this.blockTime,
  );

  Map<String, dynamic> toJson() {
    return {
      "origin": origin,
      "destination": destination,
      "ammount": ammount,
      "receivedOrNot": receivedOrNot,
      "tokenMint": programId,
      "blockNumber": blockTime
    };
  }
}

/*
 * Unsupported transactions, e.g, Tokens transactions
 */
class UnsupportedTransaction extends TransactionDetails {
  UnsupportedTransaction(int blockTime)
      : super("Unknown", "Unknown", 0.0, false, "Unknown", blockTime);
}

class Transaction {
  // Who sent the transaction
  final String origin;
  // Recipient of the transaction
  final String destination;
  // How much
  final double ammount;
  // Was the account of this transaction the same as the destination
  final bool receivedOrNot;
  // The Program ID of this transaction, e.g, System Program, Token Program...
  final String programId;
  // Token used in the transaction
  late Token token;
  // References used in the transaction, https://docs.solanapay.com/spec#reference
  late List<String> references = [];

  Transaction(
    this.origin,
    this.destination,
    this.ammount,
    this.receivedOrNot,
    this.programId,
  );
}
