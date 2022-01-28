import 'dart:async';

import 'package:solana/solana.dart';

import 'package:solana_wallet/state/tracker.dart';

class Token {
  late double balance = 0;
  late String usdBalance = "0";
  late String symbol;
  late String mint;

  Token(this.balance, this.mint, this.symbol);
}

enum AccountItem {
  Tokens,
}

class BaseAccount {
  final AccountType accountType = AccountType.Wallet;
  final String url;
  late String name;
  late bool isLoaded = true;

  late RpcClient client;
  late String address;

  late double balance = 0;
  late double usdBalance = 0;
  late TokenTrackers tokensTracker;
  late List<Transaction> transactions = [];
  late List<Token> tokens = [];

  final itemsLoaded = Map<AccountItem, bool>();

  BaseAccount(this.balance, this.name, this.url, this.tokensTracker);

  bool isItemLoaded(AccountItem item) {
    return itemsLoaded[item] != null;
  }

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);

    this.balance = balance.toDouble() / 1000000000;

    this.usdBalance = this.balance * tokensTracker.getTokenValue(system_program_id);

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
        token.usdBalance = tokenUsdBalance.toString();
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
    this.tokens = [];
    Completer completer = new Completer();

    // Get all the tokens owned by the account
    final tokenAccounts = await client.getTokenAccountsByOwner(
      address,
      TokenAccountsFilter.byProgramId(TokenProgram.programId),
      encoding: Encoding.jsonParsed,
    );

    int completedTokenAccounts = 0;

    for (final tokenAccount in tokenAccounts) {
      ParsedAccountData? data = tokenAccount.account.data as ParsedAccountData?;

      if (data != null) {
        data.when(
          splToken: (data) async {
            data.when(
                account: (mintData, type, accountType) {
                  String tokenMint = mintData.mint;
                  String? uiBalance = mintData.tokenAmount.uiAmountString;
                  double balance = double.parse(uiBalance != null ? uiBalance : "0");

                  // Start tracking the token
                  Tracker? tracker = tokensTracker.addTrackerByProgramMint(tokenMint);

                  // Get the token's symbol
                  String symbol = tracker != null
                      ? tracker.symbol
                      : tokensTracker.getTokenInfo(tokenMint).symbol;

                  // Add the token to this account
                  tokens.add(new Token(balance, tokenMint, symbol));

                  completedTokenAccounts++;

                  if (completedTokenAccounts == tokenAccounts.length) {
                    completer.complete();
                    itemsLoaded[AccountItem.Tokens] = true;
                  }
                },
                mint: (_, __, ___) {},
                unknown: (_) {});
          },
          unsupported: (_) {},
          stake: (_) {},
        );
      }
    }

    // fallback: Complete the completer if the account has no tokens
    if (tokenAccounts.length == 0) {
      completer.complete();
      itemsLoaded[AccountItem.Tokens] = true;
    }

    return completer.future;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    this.transactions = [];

    final response = await client.getTransactionsList(address);

    response.forEach((tx) {
      final message = tx.transaction.message;

      message.instructions.forEach((instruction) {
        if (instruction is ParsedInstruction) {
          ParsedInstruction parsedInstruction = instruction as ParsedInstruction;

          parsedInstruction.map(
            system: (data) {
              data.parsed.map(
                transfer: (data) {
                  ParsedSystemTransferInformation transfer = data.info;
                  bool receivedOrNot = transfer.destination == address;
                  double ammount = transfer.lamports / 1000000000;
                  this.transactions.add(
                        new Transaction(
                          transfer.source,
                          transfer.destination,
                          ammount,
                          receivedOrNot,
                        ),
                      );
                },
                transferChecked: (_) {},
                unsupported: (_) {
                  this.transactions.add(new UnsupportedTransaction());
                },
              );
            },
            splToken: (data) {
              data.parsed.map(
                transfer: (data) {
                  SplTokenTransferInfo transfer = data.info;
                  bool receivedOrNot = transfer.destination == address;
                  double ammount = double.parse(transfer.amount);
                  this.transactions.add(
                        new Transaction(
                          transfer.source,
                          transfer.destination,
                          ammount,
                          receivedOrNot,
                        ),
                      );
                },
                transferChecked: (_) {},
                generic: (_) {},
              );
            },
            memo: (_) {},
            unsupported: (_) {
              this.transactions.add(new UnsupportedTransaction());
            },
          );
        }
      });
    });
  }
}

/*
 * WalletAccount and ClientAccount implement this
 */
abstract class Account {
  final AccountType accountType;
  late String name;
  final String url;
  late bool isLoaded = true;

  late double balance = 0;
  late double usdBalance = 0;
  late String address;
  late TokenTrackers tokensTracker;
  late List<Transaction> transactions = [];
  late List<Token> tokens = [];

  Account(this.accountType, this.name, this.url);

  bool isItemLoaded(AccountItem item);
  void updateUsdFromTokenValue(Token token);
  Future<void> refreshBalance();
  Future<void> loadTransactions();
  Future<void> loadTokens();

  Map<String, dynamic> toJson();
}

class Transaction {
  final String origin;
  final String destination;
  final double ammount;
  final bool receivedOrNot;

  Transaction(this.origin, this.destination, this.ammount, this.receivedOrNot);

  Map<String, dynamic> toJson() {
    return {
      "origin": origin,
      "destination": destination,
      "ammount": ammount,
      "receivedOrNot": receivedOrNot
    };
  }

  static Transaction fromJson(dynamic tx) {
    return new Transaction(tx["origin"], tx["destination"], tx["ammount"], tx["receivedOrNot"]);
  }
}

class UnsupportedTransaction extends Transaction {
  UnsupportedTransaction() : super("Unknown", "Unknown", 0.0, false);
}
