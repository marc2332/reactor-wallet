import 'package:flutter/material.dart';
import 'package:solana/solana.dart' show RPCClient;
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';


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
    print(1);
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
    print(data);
    if (data == null) {
      print("data is null");
      return null;
    }

    var accounts = data["accounts"];
    var currentAccountName = data["currentAccountName"];

    Map<String, WalletAccount> mappedAccounts = Map();

    accounts.forEach((name, account){
      mappedAccounts[name] = WalletAccount(
        account["address"], 
        account["balance"],
        name,
        account["url"]
      );
    });

    return AppState(mappedAccounts, currentAccountName);
  }

  dynamic toJson() {
    var savedAccounts = {};
    
    accounts.forEach((name, account) {
      savedAccounts[name] = {
        "name":account.name,
        "address":account.address,
        "balance":account.balance,
        "url": account.url
      };
    });

    return {
      'accounts': savedAccounts, // FAILS
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

    print(account);

    state.accounts[account.name] = account;

    state.currentAccountName = account.name;
  }

  if(action["type"] == StateActions.RemoveAccount) {
    state.accounts.remove(action["name"]);

    if(state.currentAccountName == action["name"]) {
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

  var initialState = await persistor.load();

  if(initialState != null){

    for(var name in initialState.accounts.keys){
      var account = initialState.accounts[name];
      await account.refreshBalance();
    }

  }
  
  return Store<AppState>(
    stateReducer, 
    initialState: initialState ?? AppState(
      Map(),
      ""
    ), 
    middleware: [persistor.createMiddleware()]
    );
}
