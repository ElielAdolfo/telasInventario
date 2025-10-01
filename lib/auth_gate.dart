import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/ui/empresa_list_screen.dart';
import 'package:provider/provider.dart';
import 'auth_manager.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();
    if (auth.isLoggedIn) {
      return const EmpresaListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
