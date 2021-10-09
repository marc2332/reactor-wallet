import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:solana/solana.dart'
    show Ed25519HDKeyPair, RPCClient, TransactionResponse, Wallet;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:worker_manager/worker_manager.dart';

abstract class Account {
  final AccountType accountType;
  final String name;

  late double balance = 0;
  late double usdtBalance = 0;
  late String address;
  late double solValue = 0;
  late List<TransactionResponse> transactions = [];

  Account(this.accountType, this.name);

  Future<void> refreshBalance();
  Map<String, dynamic> toJson();
  Future<void> loadTransactions();
}

class BaseAccount {
  final AccountType accountType = AccountType.Wallet;
  final String url;
  final String name;

  late RPCClient client;
  late String address;

  late double balance = 0;
  late double usdtBalance = 0;
  late double solValue = 0;
  late List<TransactionResponse> transactions = [];

  BaseAccount(this.balance, this.name, this.url);

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdtBalance = this.balance * solValue;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    // -> https://github.com/cryptoplease/cryptoplease-dart/pull/83
    //final response = await client.getTransactionsList(address);
    //transactions = response.toList();
    transactions = [];
  }
}

/*
 * Types of accounts
 */
enum AccountType {
  Wallet,
  Client,
}

class WalletAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(double balance, name, url, this.mnemonic)
      : super(balance, name, url) {
    client = RPCClient(url);
  }

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.with_address(
      double balance, String address, name, url, this.mnemonic)
      : super(balance, name, url) {
    this.address = address;
    client = RPCClient(url);
  }

  /*
   * Create the keys pair in Isolate to prevent blocking the main thread
   */
  static Future<Ed25519HDKeyPair> createKeyPair(String mnemonic) async {
    final Ed25519HDKeyPair keyPair =
        await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    return keyPair;
  }

  /*
   * Load the keys pair into the WalletAccount
   */
  Future<void> loadKeyPair() async {
    final Ed25519HDKeyPair keyPair =
        await Executor().execute(arg1: mnemonic, fun1: createKeyPair);
    final Wallet wallet = new Wallet(signer: keyPair, rpcClient: client);
    this.wallet = wallet;
    this.address = wallet.address;
  }

  /*
   * Create a new WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(String name, String url) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = new WalletAccount(0, name, url, randomMnemonic);
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
      "accountType": accountType.toString()
    };
  }
}

/*
 * Simple Address Client to watch over an specific address
 */
class ClientAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Client;

  ClientAccount(address, double balance, name, url)
      : super(balance, name, url) {
    this.address = address;
    this.client = RPCClient(this.url);
  }

  Future<void> loadTransactions() async {
    // -> https://github.com/cryptoplease/cryptoplease-dart/pull/83
    //final response = await client.getTransactionsList(address);
    //transactions = response.toList();
    transactions = [];
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": url,
      "accountType": accountType.toString()
    };
  }
}

class AppState {
  late Map<String, Account> accounts = Map();
  late double solValue = 0;

  AppState(this.accounts);

  static AppState? fromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    try {
      Map<String, dynamic> accounts = data["accounts"];

      Map<String, Account> mappedAccounts =
          accounts.map((accountName, account) {
        // Convert enum from string to enum
        AccountType accountType =
            account["accountType"] == AccountType.Client.toString()
                ? AccountType.Client
                : AccountType.Wallet;

        if (accountType == AccountType.Client) {
          ClientAccount clientAccount = ClientAccount(
            account["address"],
            account["balance"],
            accountName,
            account["url"],
          );
          return MapEntry(accountName, clientAccount);
        } else {
          WalletAccount walletAccount = new WalletAccount.with_address(
            account["balance"],
            account["address"],
            accountName,
            account["url"],
            account["mnemonic"],
          );
          return MapEntry(accountName, walletAccount);
        }
      });

      return AppState(mappedAccounts);
    } catch (err) {
      /*
       * Restart the settings if there was any error
       */
      return AppState(Map());
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> savedAccounts =
        accounts.map((name, account) => MapEntry(name, account.toJson()));

    return {
      'accounts': savedAccounts,
    };
  }

  Future<void> loadSolValue() async {
    Map<String, String> headers = new Map();
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';

    Http.Response response = await Http.get(
      Uri.http(
        'api.coingecko.com',
        '/api/v3/simple/price',
        {
          'ids': 'solana',
          'vs_currencies': 'USD',
        },
      ),
      headers: headers,
    );

    final body = json.decode(response.body);

    solValue = body['solana']['usd'].toDouble();

    for (final account in accounts.values) {
      account.solValue = solValue;
      await account.refreshBalance();
    }
  }

  String generateAccountName() {
    int accountN = 0;
    while (accounts.containsKey("Account $accountN")) {
      accountN++;
    }
    return "Account $accountN";
  }

  void addAccount(Account account) {
    account.solValue = solValue;
    accounts[account.name] = account;
  }
}

/*
 * Extends Redux's store to make simpler some interactions to the internal state
 */
class StateWrapper extends Store<AppState> {
  StateWrapper(Reducer<AppState> reducer, initialState, middleware)
      : super(reducer, initialState: initialState, middleware: middleware);

  Future<void> refreshAccounts() async {
    // Refresh balances
    await state.loadSolValue();

    // Dispatch the change
    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Create a wallet instance
   */
  Future<void> createWallet(String accountName) async {
    // Create the account
    WalletAccount walletAccount = await WalletAccount.generate(
        accountName, "https://api.devnet.solana.com");

    // Add the account
    state.addAccount(walletAccount);

    // Refresh the balances
    await state.loadSolValue();

    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Import a wallet
   */
  Future<void> importWallet(String mnemonic) async {
    // Create the account
    WalletAccount walletAccount = new WalletAccount(
      0,
      state.generateAccountName(),
      "https://api.devnet.solana.com",
      mnemonic,
    );

    // Create key pair
    await walletAccount.loadKeyPair();

    // Add the account
    state.addAccount(walletAccount);

    // Refresh the balances
    await state.loadSolValue();

    // Dispatch the change
    dispatch({"type": StateActions.SolValueRefreshed});
  }

  /*
   * Create an address watcher
   */
  Future<void> createWatcher(String address) async {
    ClientAccount account = new ClientAccount(address, 0,
        state.generateAccountName(), "https://api.mainnet-beta.solana.com");

    // Add the account
    state.addAccount(account);

    // Refresh the balances
    await state.loadSolValue();

    dispatch({"type": StateActions.SolValueRefreshed});
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
      state.accounts
          .update(accountName, (account) => account.balance = accountBalance);
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

  AppState state = initialState ?? AppState(Map());

  final StateWrapper store = StateWrapper(
    stateReducer,
    state,
    [persistor.createMiddleware()],
  );

  // Fetch the current solana value
  state.loadSolValue().then((_) {
    for (Account account in state.accounts.values) {
      // Fetch every saved account's balance
      if (account.accountType == AccountType.Wallet) {
        account = account as WalletAccount;
        /*
         * Load the key's pair and the transactions list
         */
        account.loadKeyPair().then((_) {
          account.loadTransactions().then((_) {
            store.dispatch({
              "type": StateActions.AddAccount,
              "account": account,
            });
          });
        });
      } else {
        /*
         * Load the transactions list
         */
        account.loadTransactions().then((_) {
          store.dispatch({
            "type": StateActions.AddAccount,
            "account": account,
          });
        });
      }
    }
  });

  return store;
}
