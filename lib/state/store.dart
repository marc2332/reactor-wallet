import 'package:flutter/material.dart';
import 'package:solana/solana.dart' show Ed25519HDKeyPair, RPCClient, Wallet;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:bip39/bip39.dart' as bip39;

Future<double> solToUsdt(double sols) async {
  Map<String, String> headers = new Map();
  headers['Accept'] = 'application/json';

  Http.Response response = await Http.get(
    Uri.http('api.binance.com', '/api/v3/ticker/price', {'symbol': 'SOLUSDT'}),
    headers: headers,
  );

  final body = json.decode(response.body);

  final double value = double.parse(body['price']) * sols;

  return value;
}

abstract class Account {
  final AccountType accountType;
  final String name;
  late double balance = 0;
  late double usdtBalance = 0;
  late String address;

  Account(this.accountType, this.name);

  Future<void> refreshBalance();
  Map<String, dynamic> toJson();
}

enum AccountType { Wallet, Client }

class WalletAccount implements Account {
  final AccountType accountType = AccountType.Wallet;
  late RPCClient client;
  final String url;
  final String name;
  late String address;
  late double balance = 0;
  late double usdtBalance = 0;
  late Wallet wallet;
  late String mnemonic;

  WalletAccount(this.balance, this.name, this.url, String mnemonic) {
    this.mnemonic = mnemonic;

    client = RPCClient(url);
  }

  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdtBalance = await solToUsdt(this.balance);
  }

  Future<void> loadKeyPair() async {
    final Ed25519HDKeyPair keyPair =
        await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    final Wallet wallet = new Wallet(signer: keyPair, rpcClient: client);
    this.wallet = wallet;
    this.address = wallet.address;
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

  static Future<WalletAccount> generate(String name, String url) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = new WalletAccount(0, name, url, randomMnemonic);
    await account.loadKeyPair();
    await account.refreshBalance();
    return account;
  }

  static WalletAccount import(
      String name, String url, double balance, String mnemonic) {
    WalletAccount account = new WalletAccount(0, name, url, mnemonic);

    return account;
  }
}

class ClientAccount implements Account {
  final AccountType accountType = AccountType.Client;
  late RPCClient client;
  final String url;
  final String name;
  late String address;
  late double balance = 0;
  late double usdtBalance = 0;

  ClientAccount(this.address, this.balance, this.name, this.url) {
    client = RPCClient(this.url);
  }

  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdtBalance = await solToUsdt(this.balance);
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

  AppState(this.accounts);

  static AppState? fromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    Map<String, dynamic> accounts = data["accounts"];

    Map<String, Account> mappedAccounts = accounts.map((accountName, account) {
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
        WalletAccount walletAccount = WalletAccount.import(accountName,
            account["url"], account["balance"], account["mnemonic"]);
        return MapEntry(accountName, walletAccount);
      }
    });

    return AppState(mappedAccounts);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> savedAccounts =
        accounts.map((name, account) => MapEntry(name, account.toJson()));

    return {
      'accounts': savedAccounts,
    };
  }

  String generateAccountName() {
    int accountN = 0;
    while (accounts.containsKey("Account $accountN")) {
      accountN++;
    }
    return "Account $accountN";
  }
}

class Action {
  late StateActions type;
  dynamic payload;
}

enum StateActions { SetBalance, AddAccount, RemoveAccount }

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
      state.accounts.putIfAbsent(account.name, () => account);
      break;

    case StateActions.RemoveAccount:
      // Remove the account from the settings
      state.accounts.remove(action["name"]);

      break;
  }

  return state;
}

Future<Store<AppState>> createStore() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  AppState? initialState = await persistor.load();

  if (initialState != null) {
    for (var name in initialState.accounts.keys) {
      Account? account = initialState.accounts[name];
      // Fetch every saved account's balance
      if (account != null) {
        if (account.accountType == AccountType.Wallet) {
          account = account as WalletAccount;
          await account.loadKeyPair();
        }
        await account.refreshBalance();
      }
    }
  }

  return Store<AppState>(stateReducer,
      initialState: initialState ?? AppState(Map()),
      middleware: [persistor.createMiddleware()]);
}
