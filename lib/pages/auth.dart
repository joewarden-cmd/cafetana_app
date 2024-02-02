import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/navigation.dart';
import 'loginregister.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          if(snapshot.hasData) {
            return const NavigationWidget();
          } else {
            return const LoginRegister();
          }

        }
      ),
    );
  }
}
