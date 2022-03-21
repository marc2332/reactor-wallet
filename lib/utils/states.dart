import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/client_account.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';

final appLoadedProvider = StateProvider<bool>((_) {
  return false;
});

enum ThemeType {
  light,
  dark,
}

final settingsProvider = StateNotifierProvider<SettingsManager, Map<String, dynamic>>((ref) {
  return SettingsManager(ref);
});

final selectedAccountProvider = StateProvider<Account?>((_) {
  return null;
});

final tokensTrackerProvider = Provider<TokenTrackers>((_) {
  return TokenTrackers();
});

final accountsProvider = StateNotifierProvider<AccountsManager, Map<String, Account>>((ref) {
  TokenTrackers tokensTracker = ref.read(tokensTrackerProvider);
  return AccountsManager(tokensTracker, ref);
});

class SettingsManager extends StateNotifier<Map<String, dynamic>> {
  late Box<dynamic> settingsBox;
  final StateNotifierProviderRef ref;

  SettingsManager(this.ref) : super({}) {
    state["theme"] = ThemeType.light.name;
  }

  void setTheme(ThemeType theme) {
    settingsBox.put("theme", theme.name);
    state["theme"] = theme.name;
    state = Map.from(state);
  }

  ThemeType getTheme() {
    return mapType(state["theme"]);
  }

  static ThemeType mapType(String type) {
    switch (type) {
      case "dark":
        return ThemeType.dark;
      default:
        return ThemeType.light;
    }
  }
}

/*
 * Read, parse andl load the stored data from Hive into the state providers
 */
Future<void> loadState(TokenTrackers tokensTracker, WidgetRef ref) async {
  await Hive.initFlutter();

  // Open the settings
  Box<dynamic> settingsBox = await Hive.openBox('settings');

  // Create a settings manager
  SettingsManager settingsManager = ref.read(settingsProvider.notifier);

  // Get the saved theme
  ThemeType selectedTheme = SettingsManager.mapType(
    settingsBox.get("theme", defaultValue: "Light"),
  );

  // Configure the settings manager
  settingsManager.settingsBox = settingsBox;
  settingsManager.setTheme(selectedTheme);

  // Open the accounts
  Box<dynamic> accountsBox = await Hive.openBox('accounts');

  // Create an account manager
  AccountsManager accountManager = ref.read(accountsProvider.notifier);

  // Configure the accounts manager
  accountManager.accountsBox = accountsBox;

  // Parse the accounts into instances
  Map<dynamic, dynamic> jsonAccounts = accountsBox.toMap();

  // Map the saved accounts to instances
  Map<String, Account> accountsState = jsonAccounts.map((accountName, account) {
    AccountType accountType = account["accountType"] == AccountType.Client.toString()
        ? AccountType.Client
        : AccountType.Wallet;

    if (accountType == AccountType.Client) {
      ClientAccount clientAccount = ClientAccount(
        account["address"],
        account["balance"],
        accountName,
        NetworkUrl(account["url"][0], account["url"][1]),
        tokensTracker,
      );
      return MapEntry(accountName, clientAccount);
    } else {
      WalletAccount walletAccount = WalletAccount.withAddress(
        account["balance"],
        account["address"],
        accountName,
        NetworkUrl(account["url"][0], account["url"][1]),
        WalletAccount.decryptMnemonic(account["mnemonic"]),
        tokensTracker,
      );
      return MapEntry(accountName, walletAccount);
    }
  });

  // Load the accounts
  ref.read(accountsProvider.notifier).state = accountsState;

  // Select the first account
  if (accountsState.values.isNotEmpty) {
    ref.read(selectedAccountProvider.notifier).state = accountsState.values.first;
  }

  // Mark the app as loaded
  ref.read(appLoadedProvider.notifier).state = true;

  // Load the whole tokens list
  await tokensTracker.loadTokenList();

  // Asynchronously fetch the
  accountManager.loadUSDValues();

  int accountWithLoadedTokens = 0;

  for (Account account in accountsState.values) {
    // Fetch every saved account's balance
    if (account.accountType == AccountType.Wallet) {
      account = account as WalletAccount;

      // oad the key's pair if it's a Wallet account
      account.loadKeyPair().then((_) {
        accountManager.refreshAllState();
      });
    }

    // Load the transactions list and the tokens list
    account.loadTransactions().then((_) {
      accountManager.refreshAllState();
    });

    account.loadTokens().then((_) async {
      accountWithLoadedTokens++;

      // When all accounts have loaded it's tokens then fetch it's price
      if (accountWithLoadedTokens == accountsState.length) {
        await accountManager.loadUSDValues();
      }

      accountManager.refreshAllState();
    });
  }
}

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
