// lib/features/auth/ui/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/models/user_model.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    // Inicializar el controlador con el nombre actual si existe
    if (_displayNameController.text.isEmpty && auth.userProfile != null) {
      _displayNameController.text = auth.userProfile!.displayName;
    } else if (_displayNameController.text.isEmpty &&
        auth.user?.displayName != null) {
      _displayNameController.text = auth.user!.displayName!;
    } else if (_displayNameController.text.isEmpty &&
        auth.user?.email != null) {
      _displayNameController.text = auth.user!.email!.split('@')[0];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Bienvenido al sistema',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor completa tus datos para continuar',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Foto de perfil
              CircleAvatar(
                radius: 50,
                backgroundImage: auth.user?.photoURL != null
                    ? NetworkImage(auth.user!.photoURL!)
                    : null,
                child: auth.user?.photoURL == null
                    ? const Icon(Icons.person, size: 50)
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
              const SizedBox(height: 32),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar y continuar'),
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
      // Crear el perfil de usuario si no existe
      if (auth.userProfile == null) {
        final newUser = UserModel(
          id: auth.userId!,
          email: auth.userEmail!,
          displayName: _displayNameController.text,
          photoURL: auth.user?.photoURL,
          roles: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await auth.updateUserProfile(newUser);
      } else {
        // Actualizar el perfil existente
        final updatedUser = auth.userProfile!.copyWith(
          displayName: _displayNameController.text,
          updatedAt: DateTime.now(),
        );

        await auth.updateUserProfile(updatedUser);
      }

      // Navegar a la pantalla principal
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
