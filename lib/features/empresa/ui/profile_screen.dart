// lib/features/auth/ui/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final auth = context.read<AuthManager>();
    if (auth.userProfile != null) {
      _displayNameController.text = auth.userProfile!.displayName;
    } else if (auth.user?.displayName != null) {
      _displayNameController.text = auth.user!.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: 60,
                backgroundImage: auth.user?.photoURL != null
                    ? NetworkImage(auth.user!.photoURL!)
                    : null,
                child: auth.user?.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 16),

              // Campo de nombre
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (solo lectura)
              TextFormField(
                initialValue: auth.user?.email ?? '',
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Roles del usuario
              if (auth.userProfile?.roles.isNotEmpty ?? false) ...[
                const Text(
                  'Roles asignados:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: auth.userProfile?.roles.length ?? 0,
                    itemBuilder: (context, index) {
                      final role = auth.userProfile!.roles[index];
                      return Card(
                        child: ListTile(
                          title: Text(role.name),
                          subtitle: role.empresaNombre != null
                              ? Text('Empresa: ${role.empresaNombre}')
                              : null,
                          trailing: Text(
                            'Vence: ${role.fechaVencimiento.day}/${role.fechaVencimiento.month}/${role.fechaVencimiento.year}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Text(
                  'No tienes roles asignados',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),

              const SizedBox(height: 32),

              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final auth = context.read<AuthManager>();

    try {
      if (auth.userProfile != null) {
        // Actualizar el perfil existente
        final updatedUser = auth.userProfile!.copyWith(
          displayName: _displayNameController.text,
          updatedAt: DateTime.now(),
        );

        await auth.updateUserProfile(updatedUser);
      }

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}
