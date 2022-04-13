import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/pages/setup_password.dart';
import 'package:reactor_wallet/utils/links.dart';
import 'package:reactor_wallet/utils/state/providers.dart';
import 'package:reactor_wallet/utils/states.dart';

import 'account_selection.dart';

class WelcomePage extends HookConsumerWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensTracer = ref.read(tokensTrackerProvider);
    final encryptionKey = ref.watch(encryptionKeyProvider);
    final appLoaded = ref.watch(appLoadedProvider);

    useEffect(() {
      if (encryptionKey != null && !appLoaded) {
        loadState(tokensTracer, ref, encryptionKey);
      }
    }, [encryptionKey]);

    return Scaffold(
      body: ResponsiveSizer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 600,
              ),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                direction: Axis.vertical,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Hey 😁",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Thank you for choosing Reactor Wallet"),
                  ),
                  const Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 250,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Image(
                          width: 190,
                          height: 190,
                          image: AssetImage('assets/logo.png'),
                        ),
                      ),
                    ),
                  ),
                  if (encryptionKey == null) ...[
                    ElevatedButton(
                      onPressed: () {
                        const secureStorage = FlutterSecureStorage();
                        // Ask the user to add a password if was not found
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => SetupPasswordPage(secureStorage: secureStorage),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.security_rounded,
                                size: 17,
                              ),
                            ),
                            Text("Setup Password"),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return const AccountSelectionPage();
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("Get Started  "),
                              Icon(
                                Icons.arrow_forward_outlined,
                                size: 17,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: MaterialButton(
                      child: const Text("Made by Marc Espín with <3"),
                      onPressed: () async {
                        openURL(
                          'https://github.com/marc2332/reactor-wallet',
                          context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
