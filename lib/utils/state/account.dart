import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/accounts/client_account.dart';
import 'package:reactor_wallet/utils/state/providers.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/accounts/wallet_account.dart';

class AccountsManager extends StateNotifier<Map<String, Account>> {
  // Tokens trackers manager
  late TokenTrackers tokensTracker;
  late Box<dynamic> accountsBox;
  final StateNotifierProviderRef ref;

  AccountsManager(this.tokensTracker, this.ref) : super({});

  Future<void> loadUSDValues() async {
    List<String> tokenNames = tokensTracker.trackers.values
        .where((e) => !e.name.contains("Unknown"))
        .map((e) => e.name.toLowerCase())
        .toList();

    Map<String, double> usdValues = await getTokenUsdValue(tokenNames);

    for (var tracker in tokensTracker.trackers.values) {
      double? usdValue = usdValues[tracker.name.toLowerCase()];

      if (usdValue != null) {
        tokensTracker.setTokenValue(tracker.programMint, usdValue);
      }
    }

    for (final account in state.values) {
      await account.refreshBalance();
    }

    refreshAllState();
  }

  void selectFirstAccountIfAnySelected() {
    final selectedAccount = ref.read(selectedAccountProvider.notifier);

    selectedAccount.state ??= state.values.first;
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
  Future<void> createWallet(String accountName, NetworkUrl url) async {
    if (state.containsKey(accountName)) throw AccountAlreadyExists();

    // Create the account
    WalletAccount walletAccount = await WalletAccount.generate(accountName, url, tokensTracker);

    // Add the account
    state[walletAccount.name] = walletAccount;

    // Refresh the balances
    await loadUSDValues();

    // Mark tokens as loaded since there isn't any token to load
    walletAccount.itemsLoaded[AccountItem.tokens] = true;
    walletAccount.itemsLoaded[AccountItem.transactions] = true;

    // Add the account to the DB
    accountsBox.put(walletAccount.name, walletAccount.toJson());

    // Select this wallet if there wasn't any account created
    selectFirstAccountIfAnySelected();

    refreshAllState();
  }

  /*
   * Import a wallet
   */
  Future<WalletAccount> importWallet(String mnemonic, NetworkUrl url, String accountName) async {
    // Create the account
    WalletAccount walletAccount = WalletAccount(0, accountName, url, mnemonic, tokensTracker);

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

    // Select this wallet if there wasn't any account created
    selectFirstAccountIfAnySelected();

    refreshAllState();

    return walletAccount;
  }

  /*
   * Generate an available random name for the Account
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
  Future<ClientAccount> createWatcher(String address, NetworkUrl url, String accountName) async {
    ClientAccount account = ClientAccount(
      address,
      0,
      accountName,
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

    // Select this account if there wasn't any account created
    selectFirstAccountIfAnySelected();

    refreshAllState();

    return account;
  }

  /*
   * Refresh the balanace, tokens, and transactions of an account
   */
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

  /*
   * Remove an account
   */
  void removeAccount(Account account) {
    // Remove from the state
    state.remove(account.name);

    // Remove from the DB
    accountsBox.delete(account.name);

    refreshAllState();
  }

  /*
   * Rename an account's name
   */
  void renameAccount(Account account, String accountName) {
    if (state.containsKey(accountName)) throw AccountAlreadyExists();

    // Remove from the db and state
    accountsBox.delete(account.name);
    state.remove(account.name);

    // Rename
    account.name = accountName;

    // Re-add to the DB and state
    accountsBox.put(account.name, account.toJson());
    state.putIfAbsent(account.name, () => account);

    refreshAllState();
  }

  // Update the state
  void refreshAllState() {
    state = Map.from(state);
  }
}

class AccountAlreadyExists implements Exception {
  AccountAlreadyExists();
}
