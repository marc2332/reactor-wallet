import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsSubPage extends ConsumerStatefulWidget {
  SettingsSubPage({Key? key}) : super(key: key);

  @override
  SettingsSubPageState createState() => SettingsSubPageState();
}

/*
 * Settings sub page
 */
class SettingsSubPageState extends ConsumerState<SettingsSubPage> {
  SettingsSubPageState();

  void enableDarkTheme(bool value) {
    if (value) {
      ref.read(settingsProvider.notifier).setTheme(ThemeType.dark);
    } else {
      ref.read(settingsProvider.notifier).setTheme(ThemeType.light);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Card(
            child: InkWell(
              splashColor: Theme.of(context).hoverColor,
              onTap: () async {
                Navigator.pushNamed(context, '/manage_accounts');
              },
              child: ListTile(
                title: const Text('Manage accounts'),
                trailing: Icon(
                  Icons.manage_accounts_outlined,
                  color: Theme.of(context).iconColor,
                ),
              ),
            ),
          ),
          Card(
            child: Consumer(builder: (context, ref, _) {
              ref.watch(settingsProvider);
              ThemeType selectedTheme = ref.read(settingsProvider.notifier).getTheme();
              return InkWell(
                splashColor: Theme.of(context).hoverColor,
                onTap: () {
                  enableDarkTheme(selectedTheme == ThemeType.light);
                },
                child: ListTile(
                  title: const Text('Enable dark mode'),
                  trailing: Switch(
                    value: selectedTheme == ThemeType.dark,
                    onChanged: enableDarkTheme,
                  ),
                ),
              );
            }),
          ),
          Card(
            child: InkWell(
              splashColor: Theme.of(context).hoverColor,
              onTap: () async {
                openURL('https://github.com/marc2332/solana-mobile-wallet');
              },
              child: ListTile(
                title: const Text('Contribute'),
                trailing: Icon(
                  Icons.link_outlined,
                  color: Theme.of(context).iconColor,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Made by Marc Espín'),
              trailing: Icon(
                Icons.info_outline,
                color: Theme.of(context).iconColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  void openURL(url) async {
    bool canOpen = await canLaunch(url);

    if (canOpen) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open browser."),
        ),
      );
    }
  }
}
