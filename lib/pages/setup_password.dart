import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/utils/states.dart';
import '../components/size_wrapper.dart';

class SetupPasswordPage extends HookConsumerWidget {
  final FlutterSecureStorage secureStorage;

  const SetupPasswordPage({
    Key? key,
    required this.secureStorage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<String?> password = useState(null);
    bool isValidPassword = passwordValidator(password.value) == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Setup"),
        toolbarHeight: kToolbarHeight + 10,
      ),
      body: ResponsiveSizer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text("Write down a password to secure your wallets.")),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 80,
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintText: "Password",
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 6, right: 5),
                          child: Icon(Icons.password_sharp),
                        ),
                      ),
                      autofocus: true,
                      validator: passwordValidator,
                      onChanged: (String value) async {
                        password.value = value;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isValidPassword
                            ? () async {
                                final userPassword = password.value;
                                if (userPassword != null) {
                                  await setupPassword(userPassword, ref);
                                  Navigator.pop(context);
                                }
                              }
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),
                          child: Text("Continue"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 8) {
      return 'Password must contain atleast 8 characters';
    } else {
      return null;
    }
  }

  Future<void> setupPassword(String password, WidgetRef ref) async {
    password = password.padRight(32, "-");

    await secureStorage.write(
      key: 'encrypt_key',
      value: base64UrlEncode(password.codeUnits),
    );

    ref.read(encryptionKeyProvider.notifier).state = Uint8List.fromList(password.codeUnits);
  }
}
