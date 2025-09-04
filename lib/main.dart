import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:educativo/pages/login_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  const publishableKey =
      "pk_test_ZW5nYWdpbmctYm9uZWZpc2gtNDUuY2xlcmsuYWNjb3VudHMuZGV2JA";

  runApp(const EducativoApp(publishableKey: publishableKey));
}

/// Example App
class EducativoApp extends StatelessWidget {
  const EducativoApp({super.key, required this.publishableKey});

  final String publishableKey;

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MaterialApp(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: ClerkErrorListener(
              child: ClerkAuthBuilder(
                signedInBuilder: (context, authState) {
                  return const ClerkUserButton();
                },
                signedOutBuilder: (context, authState) {
                  return const LoginPage();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
