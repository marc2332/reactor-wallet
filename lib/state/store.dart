import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'dart:async';

import 'base_account.dart';
import 'client_account.dart';
import 'wallet_account.dart';

/*
 * Types of accounts
 */
enum AccountType {
  Wallet,
  Client,
}

const system_program_id = "11111111111111111111111111111111";
const token_program_id = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA";

/*
 * Token Tracker
 */
class Tracker {
  String name;
  String programMint;
  double usdValue = 0;
  String symbol;

  Tracker(this.name, this.programMint, this.symbol);
}

class TokenInfo {
  late String name = "Unknown";
  late String logoUrl = "";
  late String symbol = "?";

  TokenInfo();
  TokenInfo.withInfo(this.name, this.logoUrl, this.symbol);
}

/*
 * Centralized token trackers list
 */
class TokenTrackers {
  // List of Token trackers
  late Map<String, Tracker> trackers = {
    system_program_id: new Tracker('solana', system_program_id, "SOL"),
  };

  late Map tokensList;

  Future<void> loadTokenList() async {
    var tokensFile = await rootBundle.loadString('assets/tokens_list.json');
    Map tokensList = json.decode(tokensFile);
    this.tokensList = tokensList;
  }

  double getTokenValue(String programMint) {
    Tracker? token = trackers[programMint];
    if (token != null) {
      return token.usdValue;
    } else {
      return 0;
    }
  }

  Tracker? getTracker(String programMint) {
    return trackers[programMint];
  }

  void setTokenValue(String programMint, double usdValue) {
    Tracker? token = trackers[programMint];
    if (token != null) {
      token.usdValue = usdValue;
    }
  }

  TokenInfo getTokenInfo(String programId) {
    for (final token in tokensList["tokens"]) {
      if (token['address'] == programId) {
        return new TokenInfo.withInfo(token["name"], token["logoURI"], token["symbol"]);
      }
    }
    // If not info about the token is found then an "Unknown" token is returned
    return new TokenInfo();
  }

  Tracker? addTrackerByProgramMint(String programMint) {
    // Add tracker if doesn't exist yet
    if (!trackers.containsKey(programMint)) {
      TokenInfo tokenInfo = getTokenInfo(programMint);

      trackers[programMint] = new Tracker(tokenInfo.name, programMint, tokenInfo.symbol);

      return trackers[programMint];
    }
  }
}

/*
 * Fetch the USD value of a token using the Coingecko API
 */
Future<Map<String, double>> getTokenUsdValue(List<String> tokens) async {
  try {
    Map<String, String> headers = new Map();
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';
    Http.Response response = await Http.get(
      Uri.http(
        'api.coingecko.com',
        '/api/v3/simple/price',
        {
          'ids': tokens.join(','),
          'vs_currencies': 'USD',
        },
      ),
      headers: headers,
    );

    final body = json.decode(response.body) as Map;
    Map<String, double> values = {};
    for (final token in body.keys) {
      values[token] = body[token]['usd'];
    }

    return values;
  } catch (err) {
    print('$err');
    return {tokens[0]: 0};
  }
}

class AppState {
  late Map<String, Account> accounts = Map();
  late double solValue = 0;
  final TokenTrackers valuesTracker;

  AppState(this.accounts, this.valuesTracker);

  Future<void> loadUSDValues() async {
    List<String> tokenNames = valuesTracker.trackers.values
        .where((e) => e.name != "Unknown")
        .map((e) => e.name.toLowerCase())
        .toList();
    Map<String, double> usdValues = await getTokenUsdValue(tokenNames);
    valuesTracker.trackers.entries.forEach((entry) {
      Tracker tracker = entry.value;
      double? usdValue = usdValues[tracker.name.toLowerCase()];
      if (usdValue != null) {
        valuesTracker.setTokenValue(tracker.programMint, usdValue);
      }
    });

    for (final account in accounts.values) {
      await account.refreshBalance();
    }
  }

  /*
  * Generate an available random name for the new Account
  */
  String generateAccountName() {
    int accountN = 0;
    while (accounts.containsKey("Account $accountN")) {
      accountN++;
    }
    return "Account $accountN";
  }

  void addAccount(Account account) {
    account.valuesTracker = valuesTracker;
    accounts[account.name] = account;
  }

  static AppState? fromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    TokenTrackers valuesTracker = new TokenTrackers();

    try {
      Map<String, dynamic> accounts = data["accounts"];

      Map<String, Account> mappedAccounts = accounts.map((accountName, account) {
        // Convert enum from string to enum
        AccountType accountType = account["accountType"] == AccountType.Client.toString()
            ? AccountType.Client
            : AccountType.Wallet;

        if (accountType == AccountType.Client) {
          ClientAccount clientAccount = ClientAccount(
            account["address"],
            account["balance"],
            accountName,
            account["url"],
            valuesTracker,
          );
          return MapEntry(accountName, clientAccount);
        } else {
          WalletAccount walletAccount = new WalletAccount.withAddress(
            account["balance"],
            account["address"],
            accountName,
            account["url"],
            account["mnemonic"],
            valuesTracker,
          );
          return MapEntry(accountName, walletAccount);
        }
      });

      return AppState(mappedAccounts, valuesTracker);
    } catch (err) {
      print(err);
      /*
       * Restart the settings if there was any error
       */
      return AppState(Map(), valuesTracker);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> savedAccounts =
        accounts.map((name, account) => MapEntry(name, account.toJson()));

    return {
      'accounts': savedAccounts,
    };
  }
}

/*
 * Extends Redux's store to make simpler some interactions to the internal state
 */
class StateWrapper extends Store<AppState> {
  StateWrapper(Reducer<AppState> reducer, initialState, middleware)
      : super(reducer, initialState: initialState, middleware: middleware);

  Future<void> refreshAccounts() async {
    for (final account in state.accounts.values) {
      // Refresh the account transactions
      await account.loadTransactions();
      // Refresh the tokens list
      await account.loadTokens();
    }

    // Refresh all balances value
    await state.loadUSDValues();

    // Dispatch the change
    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Create a wallet instance
   */
  Future<void> createWallet(String accountName, String url) async {
    // Create the account
    WalletAccount walletAccount =
        await WalletAccount.generate(accountName, url, state.valuesTracker);

    // Add the account
    state.addAccount(walletAccount);

    // Refresh the balances
    await state.loadUSDValues();

    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Import a wallet
   */
  Future<void> importWallet(String mnemonic, String url) async {
    // Create the account
    WalletAccount walletAccount =
        new WalletAccount(0, state.generateAccountName(), url, mnemonic, state.valuesTracker);

    // Create key pair
    await walletAccount.loadKeyPair();

    // Load account transactions
    await walletAccount.loadTransactions();

    // Load account tokens
    await walletAccount.loadTokens();

    // Add the account
    state.addAccount(walletAccount);

    // Refresh the balances
    await state.loadUSDValues();

    // Dispatch the change
    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Create an address watcher
   */
  Future<void> createWatcher(String address, String url) async {
    ClientAccount account = new ClientAccount(
      address,
      0,
      state.generateAccountName(),
      url,
      state.valuesTracker,
    );

    // Load account transactions
    await account.loadTransactions();

    // Load account tokens
    await account.loadTokens();

    // Add the account
    state.addAccount(account);

    // Refresh the balances
    await state.loadUSDValues();

    dispatch({"type": StateActions.SolValueRefreshed});
  }

  Future<void> refreshAccount(String accountName) async {
    Account? account = state.accounts[accountName];

    if (account != null) {
      await account.loadTokens();
      await account.loadTransactions();
      await account.refreshBalance();

      dispatch({"type": StateActions.SolValueRefreshed});
    }
  }
}

class Action {
  late StateActions type;
  dynamic payload;
}

enum StateActions {
  SetBalance,
  AddAccount,
  RemoveAccount,
  SolValueRefreshed,
}

AppState stateReducer(AppState state, dynamic action) {
  final actionType = action['type'];

  switch (actionType) {
    case StateActions.SetBalance:
      final accountName = action['name'];
      final accountBalance = action['balance'];
      state.accounts.update(accountName, (account) => account.balance = accountBalance);
      break;

    case StateActions.AddAccount:
      Account account = action['account'];
      // Add the account to the settings
      state.addAccount(account);
      break;

    case StateActions.RemoveAccount:
      // Remove the account from the settings
      state.accounts.remove(action["name"]);
      break;

    case StateActions.SolValueRefreshed:
      break;
  }

  return state;
}

Future<StateWrapper> createStore() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Try to load the previous app state
  AppState? initialState = await persistor.load();

  AppState state = initialState ?? AppState(Map(), new TokenTrackers());

  await state.valuesTracker.loadTokenList();

  final StateWrapper store = StateWrapper(
    stateReducer,
    state,
    [persistor.createMiddleware()],
  );

  await state.loadUSDValues();

  int accountWithLoadedTokens = 0;

  for (Account account in state.accounts.values) {
    // Fetch every saved account's balance
    if (account.accountType == AccountType.Wallet) {
      account = account as WalletAccount;
      /*
       * Load the key's pair if it's a Wallet account
       */
      account.loadKeyPair().then((_) {
        store.dispatch({
          "type": StateActions.AddAccount,
          "account": account,
        });
      });
    }

    /*
     * Load the transactions list and the tokens list
     */
    account.loadTransactions().then((_) {
      store.dispatch({
        "type": StateActions.AddAccount,
        "account": account,
      });
    });

    account.loadTokens().then((_) async {
      accountWithLoadedTokens++;

      // When all accounts have loaded it's tokens then fetch it's price
      if (accountWithLoadedTokens == state.accounts.length) {
        await state.loadUSDValues();
      }

      store.dispatch({
        "type": StateActions.AddAccount,
        "account": account,
      });
    });
  }

  return store;
}
