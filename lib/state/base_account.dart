import 'dart:async';

import 'package:solana/solana.dart';
import 'package:solana_wallet/state/store.dart';

class Token {
  late double balance = 0;
  late String usdBalance = "0";
  late String mint;

  Token(this.balance, this.mint);
}

class BaseAccount {
  final AccountType accountType = AccountType.Wallet;
  final String url;
  late String name;

  late RPCClient client;
  late String address;

  late double balance = 0;
  late double usdBalance = 0;
  late TokenTrackers valuesTracker;
  late List<Transaction> transactions = [];
  late List<Token> tokens = [];

  BaseAccount(this.balance, this.name, this.url, this.valuesTracker);

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdBalance = this.balance * valuesTracker.getTokenValue(system_program_id);

    for (final token in tokens) {
      updateUsdFromTokenValue(token);
    }
  }

  void updateUsdFromTokenValue(Token token) {
    try {
      Tracker? tracker = valuesTracker.getTracker(token.mint);
      if (tracker != null) {
        double tokenUsdBalance = (token.balance * tracker.usdValue);
        token.usdBalance = tokenUsdBalance.toString();
        this.usdBalance += tokenUsdBalance;
      }
    } catch (err) {
      print(err);
    }
  }

  // ignore: avoid_init_to_null
  Future<void> loadTokens({Function(Tracker tracker)? onLoadEveryToken = null}) async {
    this.tokens = [];
    Completer completer = new Completer();

    // Fetch all the tokens (spl-program mints) owned by the specified address
    Iterable<AssociatedTokenAccount> tokenAccounts = await client.getTokenAccountsByOwner(
      owner: address,
      programId: token_program_id,
    );

    int completedTokenAccounts = 0;
    for (final tokenAccount in tokenAccounts) {
      var data = tokenAccount.account.data;
      if (data != null) {
        data.when(
          splToken: (parsed) async {
            double decimals = double.parse("1" + "0" * (parsed.info.tokenAmount.decimals));
            double balance = double.parse(parsed.info.tokenAmount.amount) / decimals;
            String tokenMint = parsed.info.mint;

            // Start tracking the token
            Tracker? tracker = valuesTracker.addTrackerByProgramMint(tokenMint);

            Token newToken = new Token(balance, tokenMint);

            if (tracker != null && onLoadEveryToken != null) {
              double usdValue = await getTokenUsdValue(tracker.name.toLowerCase());
              valuesTracker.setTokenValue(tracker.programMint, usdValue);
              onLoadEveryToken(tracker);

              // Update the total USD value
              updateUsdFromTokenValue(newToken);
            }

            // Add the token to this account
            tokens.add(newToken);

            completedTokenAccounts++;

            if (completedTokenAccounts == tokenAccounts.length) {
              completer.complete();
            }
          },
          empty: () {},
          fromBytes: (List<int> bytes) {},
          fromString: (String string) {},
          generic: (Map<String, dynamic> data) {},
        );
      }
    }

    return completer.future;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    final response = await client.getTransactionsList(address);

    response.forEach((tx) {
      ParsedMessage? message = tx.transaction.message;
      if (message != null) {
        ParsedInstruction instruction = message.instructions[0];
        dynamic res = instruction.toJson();
        if (res['program'] == 'system') {
          dynamic parsed = res['parsed'].toJson();
          switch (parsed['type']) {
            case 'transfer':
              dynamic transfer = parsed['info'].toJson();
              bool receivedOrNot = transfer['destination'] == address;
              double ammount = transfer['lamports'] / 1000000000;
              this
                  .transactions
                  .add(new Transaction(transfer['source'], transfer['destination'], ammount, receivedOrNot));
              break;
            default:
              // Unsupported transaction type
              this.transactions.add(new UnsupportedTransaction());
          }
        } else {
          // Unsupported program
          this.transactions.add(new UnsupportedTransaction());
        }
      } else {
        return;
      }
    });
  }
}

abstract class Account {
  final AccountType accountType;
  late String name;
  final String url;

  late double balance = 0;
  late double usdBalance = 0;
  late String address;
  late TokenTrackers valuesTracker;
  late List<Transaction> transactions = [];
  late List<Token> tokens = [];

  Account(this.accountType, this.name, this.url);

  void updateUsdFromTokenValue(Token token);
  Future<void> refreshBalance();
  Map<String, dynamic> toJson();
  Future<void> loadTransactions();
  // ignore: avoid_init_to_null
  Future<void> loadTokens({Function(Tracker tracker)? onLoadEveryToken = null});
}

class Transaction {
  final String origin;
  final String destination;
  final double ammount;
  final bool receivedOrNot;

  Transaction(this.origin, this.destination, this.ammount, this.receivedOrNot);

  Map<String, dynamic> toJson() {
    return {"origin": origin, "destination": destination, "ammount": ammount, "receivedOrNot": receivedOrNot};
  }

  static Transaction fromJson(dynamic tx) {
    return new Transaction(tx["origin"], tx["destination"], tx["ammount"], tx["receivedOrNot"]);
  }
}

class UnsupportedTransaction extends Transaction {
  UnsupportedTransaction() : super("Unknown", "Unknown", 0.0, false);
}
