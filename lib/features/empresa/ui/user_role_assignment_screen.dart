// lib/features/auth/ui/user_role_assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/empresa_manager.dart';
import 'package:inventario/features/empresa/logic/role_manager.dart';
import 'package:inventario/features/empresa/logic/user_manager.dart';
import 'package:inventario/features/empresa/models/role_model.dart';
import 'package:inventario/features/empresa/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:inventario/features/empresa/models/user_role.dart';

class UserRoleAssignmentScreen extends StatefulWidget {
  final UserModel user;

  const UserRoleAssignmentScreen({super.key, required this.user});

  @override
  State<UserRoleAssignmentScreen> createState() =>
      _UserRoleAssignmentScreenState();
}

class _UserRoleAssignmentScreenState extends State<UserRoleAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _selectedRoles = [];

  // Variables para el formulario actual
  RoleModel? _currentSelectedRole;
  String? _currentSelectedEmpresaId;
  String? _currentSelectedEmpresaNombre;
  DateTime _currentFechaVencimiento = DateTime(DateTime.now().year + 1, 12, 31);

  @override
  void initState() {
    super.initState();
    // Cargar empresas y roles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaManager>().loadEmpresas();
      context.read<RoleManager>().loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignar roles - ${widget.user.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAllRoles,
            tooltip: 'Guardar todos los roles',
          ),
        ],
      ),
      body: Consumer3<UserManager, EmpresaManager, RoleManager>(
        builder: (context, userManager, empresaManager, roleManager, child) {
          if (empresaManager.isLoading || roleManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (empresaManager.error != null) {
            return Center(child: Text('Error: ${empresaManager.error}'));
          }

          if (roleManager.error != null) {
            return Center(child: Text('Error: ${roleManager.error}'));
          }

          // Filtrar roles que ya están asignados al usuario
          final availableRoles = roleManager.roles.where((role) {
            return !widget.user.roles.any(
              (userRole) => userRole.roleId == role.id,
            );
          }).toList();

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del usuario
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: widget.user.photoURL != null
                            ? NetworkImage(widget.user.photoURL!)
                            : null,
                        child: widget.user.photoURL == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        widget.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(widget.user.email),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección para agregar nuevos roles
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Nuevo Rol',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Selector de rol
                          DropdownButtonFormField<RoleModel>(
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: availableRoles.map((role) {
                              return DropdownMenuItem<RoleModel>(
                                value: role,
                                child: Text(role.name),
                              );
                            }).toList(),
                            value: _currentSelectedRole,
                            onChanged: (value) {
                              setState(() {
                                _currentSelectedRole = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Seleccione un rol';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Selector de empresa
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Empresa',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: empresaManager.empresas.map((empresa) {
                              return DropdownMenuItem<String>(
                                value: empresa.id,
                                child: Text(empresa.nombre),
                              );
                            }).toList(),
                            value: _currentSelectedEmpresaId,
                            onChanged: (value) {
                              setState(() {
                                _currentSelectedEmpresaId = value;
                                if (value != null) {
                                  final empresa = empresaManager.empresas
                                      .firstWhere(
                                        (e) => e.id == value,
                                        orElse: () =>
                                            empresaManager.empresas.first,
                                      );
                                  _currentSelectedEmpresaNombre =
                                      empresa.nombre;
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Seleccione una empresa';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Selector de fecha de vencimiento
                          InkWell(
                            onTap: () => _selectFechaVencimiento(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de vencimiento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_currentFechaVencimiento.day}/${_currentFechaVencimiento.month}/${_currentFechaVencimiento.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Icon(Icons.calendar_today),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botón para agregar otro rol
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  (_currentSelectedRole != null &&
                                      _currentSelectedEmpresaId != null)
                                  ? _addNewRoleToSelection
                                  : null, // Deshabilitado si no hay selección
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar otro rol'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                disabledForegroundColor: Colors.grey
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vista previa de roles a agregar
                  if (_selectedRoles.isNotEmpty) ...[
                    const Text(
                      'Roles a agregar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedRoles.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final roleData = _selectedRoles[index];
                          return ListTile(
                            title: Text(
                              roleData['role']?.name ?? 'Rol no seleccionado',
                            ),
                            subtitle: Text(
                              'Empresa: ${roleData['empresaNombre'] ?? 'No seleccionada'}\n'
                              'Vence: ${roleData['fechaVencimiento']?.day ?? ''}/${roleData['fechaVencimiento']?.month ?? ''}/${roleData['fechaVencimiento']?.year ?? ''}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeRoleFromSelection(index),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Botón de guardar todos
                  if (_selectedRoles.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveAllRoles,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar todos los roles'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Lista de roles actuales
                  if (widget.user.roles.isNotEmpty) ...[
                    const Text(
                      'Roles actuales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height:
                          300, // Altura fija para la lista de roles actuales
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widget.user.roles.length,
                        itemBuilder: (context, index) {
                          final role = widget.user.roles[index];
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              top: 8,
                            ),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                role.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Empresa: ${role.empresaNombre ?? "No asignada"}\n'
                                'Vence: ${role.fechaVencimiento.day}/${role.fechaVencimiento.month}/${role.fechaVencimiento.year}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  // Confirmar eliminación
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Confirmar eliminación',
                                      ),
                                      content: const Text(
                                        '¿Está seguro de eliminar este rol?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await userManager.removeRoleFromUser(
                                      widget.user.id,
                                      role.id,
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  // Agregamos un espacio al final para asegurar que el último elemento no quede pegado al borde inferior
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectFechaVencimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentFechaVencimiento,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _currentFechaVencimiento) {
      setState(() {
        _currentFechaVencimiento = picked;
      });
    }
  }

  void _addNewRoleToSelection() {
    if (_currentSelectedRole == null || _currentSelectedEmpresaId == null) {
      return;
    }

    setState(() {
      _selectedRoles.add({
        'role': _currentSelectedRole,
        'empresaId': _currentSelectedEmpresaId,
        'empresaNombre': _currentSelectedEmpresaNombre,
        'fechaVencimiento': _currentFechaVencimiento,
      });

      // Limpiar selección actual para permitir agregar otro rol
      _currentSelectedRole = null;
      _currentSelectedEmpresaId = null;
      _currentSelectedEmpresaNombre = null;
      _currentFechaVencimiento = DateTime(DateTime.now().year + 1, 12, 31);
    });
  }

  void _removeRoleFromSelection(int index) {
    setState(() {
      _selectedRoles.removeAt(index);
    });
  }

  Future<void> _saveAllRoles() async {
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay roles para guardar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que todos los roles tengan datos completos
    for (int i = 0; i < _selectedRoles.length; i++) {
      final roleData = _selectedRoles[i];
      if (roleData['role'] == null || roleData['empresaId'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complete todos los datos del rol #${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Verificar duplicados
    final userManager = context.read<UserManager>();
    for (final roleData in _selectedRoles) {
      final role = roleData['role'] as RoleModel;
      final empresaId = roleData['empresaId'] as String;

      final roleAlreadyAssigned = widget.user.roles.any(
        (r) => r.roleId == role.id && r.empresaId == empresaId,
      );

      if (roleAlreadyAssigned) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El rol "${role.name}" ya está asignado para esta empresa',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Guardar todos los roles
    bool allSuccess = true;
    for (final roleData in _selectedRoles) {
      final role = roleData['role'] as RoleModel;
      final empresaId = roleData['empresaId'] as String;
      final empresaNombre = roleData['empresaNombre'] as String;
      final fechaVencimiento = roleData['fechaVencimiento'] as DateTime;

      final nuevoRol = UserRole(
        id: DateTime.now().millisecondsSinceEpoch.toString() + role.id,
        roleId: role.id,
        name: role.name,
        empresaId: empresaId,
        empresaNombre: empresaNombre,
        fechaVencimiento: fechaVencimiento,
      );

      final result = await userManager.addRoleToUser(widget.user.id, nuevoRol);

      if (!result) {
        allSuccess = false;
        break;
      }
    }

    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los roles han sido asignados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${userManager.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
