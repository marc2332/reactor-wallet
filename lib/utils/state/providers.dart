import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';
import 'package:reactor_wallet/utils/state/account.dart';
import 'package:reactor_wallet/utils/state/settings.dart';
import 'package:reactor_wallet/utils/tracker.dart';

final deepLinkProvider = StateProvider<String?>((ref) {
  return null;
});

final appLoadedProvider = StateProvider<bool>((_) {
  return false;
});

final encryptionKeyProvider = StateProvider<Uint8List?>((_) {
  return null;
});

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
