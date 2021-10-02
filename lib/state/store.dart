import 'package:solana/solana.dart' show RPCClient;
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class WalletAccount {

  final RPCClient client = RPCClient("https://api.mainnet-beta.solana.com");

  final String name;
  final String address;
  double balance;

  WalletAccount(this.address, this.balance, this.name);


  Future<double> getBalance() async {
    var balance = await client.getBalance(address);

    return balance.toDouble() / 1000000000;
  }
}

class AppState {
  

  final accounts = Map();
  late String currentAccountName;

  WalletAccount getCurrentAccount(){
    return accounts[currentAccountName];
  }

}

class Action {
  late StateActions type;
  dynamic payload;
}

enum StateActions { 
  SetBalance,
  AddAccount
}

AppState stateReducer(AppState state, dynamic action) {

  if (action["type"] == StateActions.SetBalance) {
    state.accounts[action["name"]].balance = action["balance"];
  }

   if (action["type"] == StateActions.AddAccount) {

    var account = action["account"];

    state.accounts[account.name] = account;


  }


  return state;
}

Store<AppState> createStore() {
  return Store<AppState>(stateReducer, initialState: AppState());
}