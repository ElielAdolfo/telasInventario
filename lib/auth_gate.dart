// lib/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/ui/complete_profile_screen.dart';
import 'package:inventario/features/empresa/ui/empresa_list_screen.dart';
import 'package:inventario/features/empresa/ui/role_selection_screen.dart';
import 'package:inventario/features/empresa/ui/tienda_list_screen.dart';
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
        
        // Si tiene roles pero no ha seleccionado uno, mostrar selección de rol
        if (auth.hasAvailableRoles() && auth.selectedRole == null) {
          return const RoleSelectionScreen();
        }
        
        // Si ya tiene un rol seleccionado, navegar según el rol
        if (auth.selectedRole != null) {
          switch (auth.selectedRole!.name.toLowerCase()) {
            case 'administrador':
              return const EmpresaListScreen();
            case 'gerente':
              return const EmpresaListScreen();
            case 'vendedor':
              // Verificar si tiene empresa asignada
              if (auth.selectedRole?.empresaId == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Acceso denegado')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes una empresa asignada',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Volver a la selección de roles
                            auth.selectRole(null);
                          },
                          child: const Text('Seleccionar otro rol'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return TiendaListScreen(
                empresaId: auth.selectedRole!.empresaId!,
                empresaNombre: auth.selectedRole!.empresaNombre ?? '',
              );
          }
        }
        
        // Por defecto, mostrar selección de rol
        return const RoleSelectionScreen();
      },
    );
  }
}