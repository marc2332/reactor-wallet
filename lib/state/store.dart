import 'package:flutter/material.dart';
import 'package:solana/solana.dart' show RPCClient;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;

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

class WalletAccount {
  late RPCClient client;

  final String url;
  final String name;
  final String address;
  late double balance;
  late double usdtBalance = 0;

  WalletAccount(this.address, this.balance, this.name, this.url) {
    client = RPCClient(this.url);
  }

  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdtBalance = await solToUsdt(this.balance);
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "address": address, "balance": balance, "url": url};
  }
}

class AppState {
  var accounts = Map();
  late String currentAccountName;

  AppState(this.accounts, this.currentAccountName);

  WalletAccount? getCurrentAccount() {
    return accounts[currentAccountName];
  }

  static AppState? fromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    Map<String, dynamic> accounts = data["accounts"];
    String currentAccountName = data["currentAccountName"];

    Map<String, WalletAccount> mappedAccounts = accounts.map(
      (name, account) => MapEntry(
        name,
        WalletAccount(
          account["address"],
          account["balance"],
          name,
          account["url"],
        ),
      ),
    );

    return AppState(mappedAccounts, currentAccountName);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> savedAccounts =
        accounts.map((name, account) => MapEntry(name, account.toJson()));

    return {
      'accounts': savedAccounts,
      'currentAccountName': currentAccountName
    };
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
      state.accounts[accountName].balance = accountBalance;
      break;

    case StateActions.AddAccount:
      final Map<String, dynamic> account = action['balance'];
      final accountName = account['name'];

      // Add the account to the settings
      state.accounts[accountName] = account;

      // Select it as the current one
      state.currentAccountName = accountName;

      break;

    case StateActions.RemoveAccount:
      // Remove the account from the settings
      state.accounts.remove(action["name"]);

      /*
        * Select the first configured account if available
        */
      if (state.accounts.isNotEmpty) {
        WalletAccount account = state.accounts.entries.first as WalletAccount;
        state.currentAccountName = account.name;
      } else {
        state.currentAccountName = "";
      }
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
      WalletAccount account = initialState.accounts[name];
      // Fetch every saved account's balance
      await account.refreshBalance();
    }
  }

  return Store<AppState>(stateReducer,
      initialState: initialState ?? AppState(Map(), ""),
      middleware: [persistor.createMiddleware()]);
}
