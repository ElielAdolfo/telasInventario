// lib/features/auth/ui/user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/user_manager.dart';
import 'package:inventario/features/empresa/models/user_model.dart';
import 'package:provider/provider.dart';
import 'user_role_assignment_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManager>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Consumer<UserManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          if (manager.users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadUsers(),
            child: ListView.builder(
              itemCount: manager.users.length,
              itemBuilder: (context, index) {
                final user = manager.users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.assignment_ind),
                          onPressed: () =>
                              _navigateToRoleAssignment(context, user),
                          tooltip: 'Asignar rol y empresa',
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
    );
  }

  void _navigateToRoleAssignment(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRoleAssignmentScreen(user: user),
      ),
    );
  }
}
