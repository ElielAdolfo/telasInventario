// lib/features/auth/ui/role_management_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/role_manager.dart';
import 'package:inventario/features/empresa/models/role_model.dart';
import 'package:provider/provider.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleManager>().loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Roles')),
      body: Consumer<RoleManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadRoles(),
            child: ListView.builder(
              itemCount: manager.roles.length,
              itemBuilder: (context, index) {
                final role = manager.roles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(role.name),
                    subtitle: role.description != null
                        ? Text(role.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditRoleDialog(context, role),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteRole(context, role),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del rol'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newRole = RoleModel(
                  id: '', // Se generará automáticamente
                  name: nameController.text,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                );

                final success = await context.read<RoleManager>().addRole(
                  newRole,
                );
                if (success) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, RoleModel role) {
    final nameController = TextEditingController(text: role.name);
    final descriptionController = TextEditingController(
      text: role.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del rol'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final updatedRole = role.copyWith(
                  name: nameController.text,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                );

                final success = await context.read<RoleManager>().updateRole(
                  updatedRole,
                );
                if (success) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el rol "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<RoleManager>().deleteRole(
                role.id,
              );
              if (success) {
                Navigator.pop(context);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
