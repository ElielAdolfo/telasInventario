// lib/features/auth/ui/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/models/user_role.dart';
import 'package:inventario/features/empresa/ui/empresa_list_screen.dart';
import 'package:inventario/features/empresa/ui/tienda_list_screen.dart';
import 'package:provider/provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, auth, child) {
        // Si no está autenticado, redirigir al login
        if (!auth.isLoggedIn) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si no tiene roles asignados
        if (!auth.hasAvailableRoles()) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Sin roles asignados'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes roles asignados',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Por favor contacta al administrador',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => auth.signOut(),
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          );
        }

        final roles = auth.userProfile!.roles;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Seleccionar rol'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.signOut(),
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${auth.userProfile?.displayName ?? auth.user?.email}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un rol para continuar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // Seleccionar el rol
                          auth.selectRole(role);
                          
                          // Verificar si cumple con los requisitos
                          final meetsRequirements = await auth.meetsRoleRequirements(role.name);
                          if (!meetsRequirements) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No cumples con los requisitos para el rol de ${role.name}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // Navegar a la pantalla correspondiente según el rol
                          switch (role.name.toLowerCase()) {
                            case 'administrador':
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmpresaListScreen(),
                                ),
                                (route) => false,
                              );
                              break;
                            case 'gerente':
                              // Verificar si tiene empresa asignada
                              if (role.empresaId == null || role.empresaNombre == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No tienes una empresa asignada'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmpresaListScreen(),
                                ),
                                (route) => false,
                              );
                              break;
                            case 'vendedor':
                              // Verificar si tiene empresa asignada
                              if (role.empresaId == null || role.empresaNombre == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No tienes una empresa asignada'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TiendaListScreen(
                                    empresaId: role.empresaId!,
                                    empresaNombre: role.empresaNombre!,
                                  ),
                                ),
                                (route) => false,
                              );
                              break;
                            default:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rol no reconocido: ${role.name}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getRoleIcon(role.name),
                                  color: Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (role.empresaNombre != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Empresa: ${role.empresaNombre}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Vence: ${role.fechaVencimiento.day}/${role.fechaVencimiento.month}/${role.fechaVencimiento.year}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getRoleIcon(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'gerente':
        return Icons.business;
      case 'vendedor':
        return Icons.shopping_cart;
      case 'almacenero':
        return Icons.inventory;
      default:
        return Icons.assignment_ind;
    }
  }
}