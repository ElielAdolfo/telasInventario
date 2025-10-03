// lib/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/ui/complete_profile_screen.dart';
import 'package:inventario/features/empresa/ui/empresa_list_screen.dart';
import 'package:inventario/login_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, auth, child) {
        // Si está cargando, mostrar indicador
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Si no está autenticado, mostrar login
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }
        
        // Si es primer inicio de sesión, mostrar completar perfil
        if (auth.isFirstLogin) {
          return const CompleteProfileScreen();
        }
        
        // Si todo está correcto, mostrar la aplicación principal
        return const EmpresaListScreen();
      },
    );
  }
}