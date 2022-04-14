import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/pages/welcome.dart';
import 'package:reactor_wallet/utils/state/providers.dart';

import '../utils/states.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensTracer = ref.read(tokensTrackerProvider);
    final accounts = ref.watch(accountsProvider).values.toList();
    final appLoaded = ref.watch(appLoadedProvider);
    final encryptedKey = ref.watch(encryptionKeyProvider);

    // Load the app's state when the encryption key is retrieved
    useEffect(() {
      if (encryptedKey != null && !appLoaded) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          await loadState(
            tokensTracer,
            ref,
            encryptedKey,
          );
        });
      }

      return null;
    }, [encryptedKey]);

    // Load /welcome or /home when the app loads
    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        if (appLoaded) {
          if (accounts.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed("/home");
          } else {
            // Go to the welcome page if no account is found
            Navigator.of(context)
                .pushReplacement(CupertinoPageRoute(builder: (_) => const WelcomePage()));
          }
        }
      });

      return null;
    }, [appLoaded]);

    // Retrieve the encryption key if exists
    useEffect(() {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        const secureStorage = FlutterSecureStorage();
        secureStorage.read(key: 'encrypt_key').then(
          (encryprionKey) async {
            if (encryprionKey != null) {
              Uint8List newEncryptedKey = base64Url.decode(encryprionKey);
              ref.read(encryptionKeyProvider.notifier).state = newEncryptedKey;
            } else {
              Navigator.of(context).pushReplacementNamed("/welcome");
            }
          },
        );
      });
    }, []);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: const [
                SizedBox(
                  height: 250,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Image(
                      width: 190,
                      height: 190,
                      image: AssetImage('assets/logo.png'),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
