import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/pages/manage_accounts.dart';
import 'home/account.dart';
import 'home/settings.dart';

/*
 * Home Page
 */
class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (currentPage) {
      // Settings sub page
      case 4:
        page = const SettingsSubPage();
        break;

      case 3:
        page = const ManageAccountsPage();
        break;

      case 2:
        page = const AccountSubPage("/collectibles");
        break;

      // Settings sub page
      case 1:
        page = const AccountSubPage("/transactions");
        break;

      // Account sub page
      default:
        page = const AccountSubPage("/home");
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: ResponsiveSizer(
        child: BottomNavigationBar(
          onTap: (int page) {
            setState(() {
              currentPage = page;
            });
          },
          elevation: 0,
          showUnselectedLabels: Platform.isWindows | Platform.isMacOS | Platform.isLinux,
          currentIndex: currentPage,
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
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.art_track_outlined),
              icon: Icon(Icons.art_track_outlined),
              label: 'Collectibles',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.account_box_outlined),
              icon: Icon(Icons.account_box_outlined),
              label: 'Accounts',
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
