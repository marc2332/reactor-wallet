import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/size_wrapper.dart';
import '../utils/links.dart';
import 'account_selection.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  ElevatedButton(
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
