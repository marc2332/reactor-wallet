import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/utils/state/providers.dart';
import 'home/account.dart';
import 'home/settings.dart';

/*
 * Home Page
 */
class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget page;

    final currentPage = useState(0);

    switch (currentPage.value) {
      case 3:
        page = const SettingsSubPage();
        break;

      case 2:
        page = const AccountSubPage("/collectibles");
        break;

      case 1:
        page = const AccountSubPage("/transactions");
        break;

      default:
        page = const AccountSubPage("/home");
    }

    final accounts = ref.watch(accountsProvider);

    useEffect(() {
      if (accounts.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Navigator.of(context).pushNamedAndRemoveUntil("/account_selection", (_) => false);
        });
      }
      return null;
    }, [accounts, currentPage.value]);

    return Scaffold(
      body: page,
      bottomNavigationBar: ResponsiveSizer(
        child: BottomNavigationBar(
          onTap: (int page) {
            currentPage.value = page;
          },
          elevation: 0,
          showUnselectedLabels: Platform.isWindows | Platform.isMacOS | Platform.isLinux,
          currentIndex: currentPage.value,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.account_balance_wallet),
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.timeline),
              icon: Icon(Icons.timeline),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.art_track_outlined),
              icon: Icon(Icons.art_track_outlined),
              label: 'Collectibles',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
