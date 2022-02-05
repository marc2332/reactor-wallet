import 'dart:async';

import 'package:solana/solana.dart';
import 'package:reactor_wallet/components/network_selector.dart';

import 'package:reactor_wallet/utils/tracker.dart';

class Token {
  late double balance = 0;
  late double usdBalance = 0;
  late String symbol;
  late String mint;

  Token(this.balance, this.mint, this.symbol);
}

enum AccountItem { tokens, usdBalance, solBalance, transactions }

class BaseAccount {
  final AccountType accountType = AccountType.Wallet;
  final NetworkUrl url;
  late String name;
  late bool isLoaded = true;

  late SolanaClient client;
  late String address;

  late double balance = 0;
  late double usdBalance = 0;
  late TokenTrackers tokensTracker;
  late List<TransactionDetails> transactions = [];
  late List<Token> tokens = [];

  final itemsLoaded = <AccountItem, bool>{};

  BaseAccount(this.balance, this.name, this.url, this.tokensTracker);

  bool isItemLoaded(AccountItem item) {
    return itemsLoaded[item] != null;
  }

  Token getTokenByMint(String mint) {
    return tokens.firstWhere((token) => token.mint == mint);
  }

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.rpcClient.getBalance(address);

    this.balance = balance.toDouble() / 1000000000;
    itemsLoaded[AccountItem.solBalance] = true;

    this.usdBalance = this.balance * tokensTracker.getTokenValue(system_program_id);

    itemsLoaded[AccountItem.usdBalance] = true;

    for (final token in tokens) {
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
        this.usdBalance += tokenUsdBalance;
      }
    } catch (err) {
      print(err);
    }
  }

  /*
    * Loads all the tokens (spl-program mints) owned by this account
   */
  Future<void> loadTokens() async {
    tokens = [];

    // Get all the tokens owned by the account
    final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilter.byProgramId(TokenProgram.programId),
      encoding: Encoding.jsonParsed,
    );

    for (final tokenAccount in tokenAccounts) {
      ParsedAccountData? data = tokenAccount.account.data as ParsedAccountData?;

      if (data != null) {
        data.when(
          splToken: (data) {
            data.when(
                account: (mintData, type, accountType) {
                  String tokenMint = mintData.mint;
                  String? uiBalance = mintData.tokenAmount.uiAmountString;
                  double balance = double.parse(uiBalance ?? "0");

                  // Start tracking the token
                  Tracker? tracker = tokensTracker.addTrackerByProgramMint(tokenMint);

                  // Get the token's symbol
                  String symbol = tracker != null
                      ? tracker.symbol
                      : tokensTracker.getTokenInfo(tokenMint).symbol;

                  // Add the token to this account
                  tokens.add(Token(balance, tokenMint, symbol));
                },
                mint: (_, __, ___) {},
                unknown: (_) {});
          },
          unsupported: (_) {},
          stake: (_) {},
        );
      }
    }

    itemsLoaded[AccountItem.tokens] = true;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    transactions = [];

    final response = await client.rpcClient.getTransactionsList(address);

    for (var tx in response) {
      final message = tx.transaction.message;

      for (var instruction in message.instructions) {
        if (instruction is ParsedInstruction) {
          instruction.map(
            system: (data) {
              data.parsed.map(
                transfer: (data) {
                  ParsedSystemTransferInformation transfer = data.info;
                  bool receivedOrNot = transfer.destination == address;
                  double ammount = transfer.lamports.toDouble() / 1000000000;

                  transactions.add(
                    TransactionDetails(
                      transfer.source,
                      transfer.destination,
                      ammount,
                      receivedOrNot,
                      system_program_id,
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
                transferChecked: (_) {},
                generic: (_) {},
              );
            },
            memo: (_) {},
            unsupported: (_) {
              transactions.add(UnsupportedTransaction(tx.blockTime!));
            },
          );
        }
      }
    }

    itemsLoaded[AccountItem.transactions] = true;
  }
}

/*
 * WalletAccount and ClientAccount implement this
 */
abstract class Account {
  final AccountType accountType;
  late String name;
  final NetworkUrl url;
  late bool isLoaded = true;
  late SolanaClient client;

  late double balance = 0;
  late double usdBalance = 0;
  late String address;
  late TokenTrackers tokensTracker;
  late List<TransactionDetails> transactions = [];
  late List<Token> tokens = [];

  Account(this.accountType, this.name, this.url);

  bool isItemLoaded(AccountItem item);
  void updateUsdFromTokenValue(Token token);
  Future<void> refreshBalance();
  Future<void> loadTransactions();
  Future<void> loadTokens();

  Map<String, dynamic> toJson();
}

class TransactionDetails {
  final String origin;
  final String destination;
  final double ammount;
  final bool receivedOrNot;
  final String programId;
  late String tokenMint;
  final int blockTime;

  TransactionDetails(this.origin, this.destination, this.ammount, this.receivedOrNot,
      this.programId, this.blockTime);

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

class Transaction {
  final String origin;
  final String destination;
  final double ammount;
  final bool receivedOrNot;
  final String programId;
  late String tokenMint;

  Transaction(this.origin, this.destination, this.ammount, this.receivedOrNot, this.programId);
}

class UnsupportedTransaction extends TransactionDetails {
  UnsupportedTransaction(int blockTime)
      : super("Unknown", "Unknown", 0.0, false, "Unknown", blockTime);
}
