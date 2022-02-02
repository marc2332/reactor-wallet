import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana_wallet/components/network_selector.dart';
import 'package:solana_wallet/utils/base_account.dart';
import 'package:solana_wallet/utils/client_account.dart';
import 'package:solana_wallet/utils/tracker.dart';
import 'package:solana_wallet/utils/wallet_account.dart';

final appLoadedProvider = StateProvider<bool>((_) {
  return false;
});

enum ThemeType {
  Light,
  Dark,
}

final settingsProvider = StateNotifierProvider<SettingsManager, Map<String, dynamic>>((ref) {
  return SettingsManager(ref);
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

class SettingsManager extends StateNotifier<Map<String, dynamic>> {
  late Box<dynamic> settingsBox;
  final StateNotifierProviderRef ref;

  SettingsManager(this.ref) : super(new Map()) {
    state["theme"] = ThemeType.Light.name;
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
      case "Dark":
        return ThemeType.Dark;
      default:
        return ThemeType.Light;
    }
  }
}

NetworkUrl migrateFromOldUrls(dynamic url) {
  if (url is List) {
    return NetworkUrl(url[0], url[1]);
  } else {
    return NetworkUrl(url, (url as String).replaceFirst("https", "wss"));
  }
}

Future<void> loadState(TokenTrackers tokensTracker, WidgetRef ref) async {
  await Hive.initFlutter();

  // Selected the configured theme
  Box<dynamic> settingsBox = await Hive.openBox('settings');
  SettingsManager settingsManager = ref.read(settingsProvider.notifier);
  ThemeType selectedTheme = SettingsManager.mapType(
    settingsBox.get("theme", defaultValue: "Light"),
  );
  settingsManager.settingsBox = settingsBox;
  settingsManager.setTheme(selectedTheme);

  // Load the accounts
  Box<dynamic> accountsBox = await Hive.openBox('accounts');
  AccountsManager manager = ref.read(accountsProvider.notifier);
  manager.accountsBox = accountsBox;

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
        migrateFromOldUrls(account["url"]),
        tokensTracker,
      );
      return MapEntry(accountName, clientAccount);
    } else {
      WalletAccount walletAccount = WalletAccount.withAddress(
        account["balance"],
        account["address"],
        accountName,
        migrateFromOldUrls(account["url"]),
        WalletAccount.decryptMnemonic(account["mnemonic"]),
        tokensTracker,
      );
      return MapEntry(accountName, walletAccount);
    }
  });

  ref.read(accountsProvider.notifier).state = accountsMap;
  Map<String, Account> state = ref.read(accountsProvider.notifier).state;

  if (state.values.isNotEmpty) {
    ref.read(selectedAccountProvider.notifier).state = state.values.first;
  }

  ref.read(appLoadedProvider.notifier).state = true;

  await tokensTracker.loadTokenList();

  manager.loadUSDValues();

  int accountWithLoadedTokens = 0;

  for (Account account in state.values) {
    // Fetch every saved account's balance
    if (account.accountType == AccountType.Wallet) {
      account = account as WalletAccount;
      /*
        * Load the key's pair if it's a Wallet account
        */
      account.loadKeyPair().then((_) {
        manager.refreshAllState();
      });
    }

    /*
      * Load the transactions list and the tokens list
      */
    account.loadTransactions().then((_) {
      manager.refreshAllState();
    });

    account.loadTokens().then((_) async {
      accountWithLoadedTokens++;

      // When all accounts have loaded it's tokens then fetch it's price
      if (accountWithLoadedTokens == state.length) {
        await manager.loadUSDValues();
      }

      manager.refreshAllState();
    });
  }
}

class AccountsManager extends StateNotifier<Map<String, Account>> {
  // Tokens trackers manager
  late TokenTrackers tokensTracker;
  late Box<dynamic> accountsBox;
  final StateNotifierProviderRef ref;

  AccountsManager(this.tokensTracker, this.ref) : super(new Map());

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
  Future<void> createWallet(String accountName, NetworkUrl url) async {
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
  Future<WalletAccount> importWallet(String mnemonic, NetworkUrl url) async {
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
  Future<ClientAccount> createWatcher(String address, NetworkUrl url) async {
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
