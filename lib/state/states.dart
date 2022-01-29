import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/state/base_account.dart';
import 'package:solana_wallet/state/client_account.dart';
import 'package:solana_wallet/state/tracker.dart';
import 'package:solana_wallet/state/wallet_account.dart';

final appLoadedProvider = StateProvider<bool>((_) {
  return false;
});

final selectedAccountProvider = StateProvider<Account?>((_) {
  return null;
});

final tokensTrackerProvider = Provider<TokenTrackers>((_) {
  return new TokenTrackers();
});

final accountsProvider = StateNotifierProvider<AccountsManager, Map<String, Account>>((ref) {
  TokenTrackers tokensTracker = ref.read(tokensTrackerProvider);
  return new AccountsManager(tokensTracker, ref);
});

class AccountsManager extends StateNotifier<Map<String, Account>> {
  // Tokens trackers manager
  late TokenTrackers tokensTracker;
  late Box<dynamic> accountsBox;
  final StateNotifierProviderRef ref;

  AccountsManager(this.tokensTracker, this.ref) : super(new Map()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    await Hive.initFlutter();

    accountsBox = await Hive.openBox('accounts');

    Map<dynamic, dynamic> jsonAccounts = accountsBox.toMap();

    Map<String, Account> accountsMap = jsonAccounts.map((accountName, account) {
      AccountType accountType = account["accountType"] == AccountType.Client.toString()
          ? AccountType.Client
          : AccountType.Wallet;

      if (accountType == AccountType.Client) {
        ClientAccount clientAccount = ClientAccount(
          account["address"],
          account["balance"],
          accountName,
          account["url"],
          tokensTracker,
        );
        return MapEntry(accountName, clientAccount);
      } else {
        WalletAccount walletAccount = WalletAccount.withAddress(
          account["balance"],
          account["address"],
          accountName,
          account["url"],
          WalletAccount.decryptMnemonic(account["mnemonic"]),
          tokensTracker,
        );
        return MapEntry(accountName, walletAccount);
      }
    });

    state = accountsMap;

    if (state.values.isNotEmpty) {
      ref.read(selectedAccountProvider.notifier).state = state.values.first;
    }

    ref.read(appLoadedProvider.notifier).state = true;

    await tokensTracker.loadTokenList();

    loadUSDValues();

    int accountWithLoadedTokens = 0;

    for (Account account in state.values) {
      // Fetch every saved account's balance
      if (account.accountType == AccountType.Wallet) {
        account = account as WalletAccount;
        /*
        * Load the key's pair if it's a Wallet account
        */
        account.loadKeyPair().then((_) {
          refreshAllState();
        });
      }

      /*
      * Load the transactions list and the tokens list
      */
      account.loadTransactions().then((_) {
        refreshAllState();
      });

      account.loadTokens().then((_) async {
        accountWithLoadedTokens++;

        // When all accounts have loaded it's tokens then fetch it's price
        if (accountWithLoadedTokens == state.length) {
          await loadUSDValues();
        }

        refreshAllState();
      });
    }
  }

  Future<void> loadUSDValues() async {
    List<String> tokenNames = tokensTracker.trackers.values
        .where((e) => e.name != "Unknown")
        .map((e) => e.name.toLowerCase())
        .toList();

    Map<String, double> usdValues = await getTokenUsdValue(tokenNames);

    tokensTracker.trackers.values.forEach((tracker) {
      double? usdValue = usdValues[tracker.name.toLowerCase()];

      if (usdValue != null) {
        tokensTracker.setTokenValue(tracker.programMint, usdValue);
      }
    });

    for (final account in state.values) {
      await account.refreshBalance();
    }

    refreshAllState();
  }

  Future<void> refreshAccounts() async {
    for (final account in state.values) {
      // Refresh the account transactions
      await account.loadTransactions();
      // Refresh the tokens list
      await account.loadTokens();
    }

    // Refresh all balances value
    await loadUSDValues();

    // It is not necessary to save it to the DB again

    refreshAllState();
  }

  /*
   * Create a wallet instance
   */
  Future<void> createWallet(String accountName, String url) async {
    // Create the account
    WalletAccount walletAccount = await WalletAccount.generate(accountName, url, tokensTracker);

    // Add the account
    state[walletAccount.name] = walletAccount;

    // Refresh the balances
    await loadUSDValues();

    // Add the account to the DB
    accountsBox.put(walletAccount.name, walletAccount.toJson());

    refreshAllState();
  }

  /*
   * Import a wallet
   */
  Future<WalletAccount> importWallet(String mnemonic, String url) async {
    // Create the account
    WalletAccount walletAccount =
        new WalletAccount(0, generateAccountName(), url, mnemonic, tokensTracker);

    // Create key pair
    await walletAccount.loadKeyPair();

    // Load account transactions
    await walletAccount.loadTransactions();

    // Load account tokens
    await walletAccount.loadTokens();

    // Add the account to the state
    state[walletAccount.name] = walletAccount;

    // Refresh the balances
    await loadUSDValues();

    // Add the account to the DB
    accountsBox.put(walletAccount.name, walletAccount.toJson());

    refreshAllState();

    return walletAccount;
  }

  /*
  * Generate an available random name for the new Account
  */
  String generateAccountName() {
    int accountN = 0;
    while (state.containsKey("Account $accountN")) {
      accountN++;
    }
    return "Account $accountN";
  }

  /*
   * Create an address watcher
   */
  Future<ClientAccount> createWatcher(String address, String url) async {
    ClientAccount account = new ClientAccount(
      address,
      0,
      generateAccountName(),
      url,
      tokensTracker,
    );

    // Load account transactions
    await account.loadTransactions();

    // Load account tokens
    await account.loadTokens();

    // Add the account to the state
    state[account.name] = account;

    // Refresh the balances
    await loadUSDValues();

    // Add  the account to the DB
    accountsBox.put(account.name, account.toJson());

    refreshAllState();

    return account;
  }

  Future<void> refreshAccount(String accountName) async {
    Account? account = state[accountName];

    if (account != null) {
      await account.loadTokens();
      await account.loadTransactions();
      await account.refreshBalance();

      // It is not necessary to save it to the DB again
    }

    refreshAllState();
  }

  void removeAccount(Account account) {
    // Remove from the state
    state.remove(account.name);

    // Remove from the DB
    accountsBox.delete(account.name);

    refreshAllState();
  }

  void renameAccount(Account account, String name) {
    accountsBox.delete(account.name);

    account.name = name;

    accountsBox.put(account.name, account.toJson());

    refreshAllState();
  }

  // Update the state
  void refreshAllState() {
    state = new Map.from(state);
  }
}
