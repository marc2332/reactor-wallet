import 'package:flutter/material.dart';
import 'package:solana/solana.dart' show RPCClient;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

class WalletAccount {
  late RPCClient client;

  final String url;
  final String name;
  final String address;
  double balance;

  WalletAccount(this.address, this.balance, this.name, this.url) {
    client = RPCClient(this.url);
  }

  Future<void> refreshBalance() async {
    var balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
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

    var accounts = data["accounts"];
    var currentAccountName = data["currentAccountName"];

    Map<String, WalletAccount> mappedAccounts = Map();

    accounts.forEach((name, account) {
      mappedAccounts[name] = WalletAccount(
          account["address"], account["balance"], name, account["url"]);
    });

    return AppState(mappedAccounts, currentAccountName);
  }

  dynamic toJson() {
    var savedAccounts = {};

    accounts.forEach((name, account) {
      savedAccounts[name] = {
        "name": account.name,
        "address": account.address,
        "balance": account.balance,
        "url": account.url
      };
    });

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
  if (action["type"] == StateActions.SetBalance) {
    state.accounts[action["name"]].balance = action["balance"];
  }

  if (action["type"] == StateActions.AddAccount) {
    var account = action["account"];

    state.accounts[account.name] = account;

    state.currentAccountName = account.name;
  }

  if (action["type"] == StateActions.RemoveAccount) {
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
      var account = initialState.accounts[name];
      // Fetch every saved account's balance
      await account.refreshBalance();
    }
  }

  return Store<AppState>(stateReducer,
      initialState: initialState ?? AppState(Map(), ""),
      middleware: [persistor.createMiddleware()]);
}
