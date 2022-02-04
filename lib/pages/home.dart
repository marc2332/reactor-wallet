import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'home/account.dart';
import 'home/settings.dart';

/*
 * Home Page
 */
class HomePage extends ConsumerStatefulWidget {
  HomePage({Key? key}) : super(key: key);

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
      case 2:
        page = SettingsSubPage();
        break;

      // Settings sub page
      case 1:
        page = AccountSubPage("/transactions");
        break;

      // Account sub page
      default:
        page = AccountSubPage("/home");
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: BottomNavigationBar(
          onTap: (int page) {
            setState(() {
              currentPage = page;
            });
          },
          elevation: 0,
          currentIndex: currentPage,
          showUnselectedLabels: false,
          items: [
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
