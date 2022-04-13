import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/network_selector.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/accounts/client_account.dart';
import 'package:reactor_wallet/utils/state/account.dart';
import 'package:reactor_wallet/utils/state/providers.dart';
import 'package:reactor_wallet/utils/state/settings.dart';
import 'package:reactor_wallet/utils/tracker.dart';
import 'package:reactor_wallet/utils/accounts/wallet_account.dart';

/*
 * Read, parse andl load the stored data from Hive into the state providers
 */
Future<void> loadState(TokenTrackers tokensTracker, WidgetRef ref, Uint8List? encryptionKey) async {
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
  Box<dynamic> accountsBox = await Hive.openBox('accounts',
      encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null);

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
        account["mnemonic"],
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
