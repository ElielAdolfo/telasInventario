// lib/features/empresa/ui/empresa_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/models/empresa_model.dart';
import 'package:inventario/features/empresa/ui/asignar_stock_tienda_screen.dart';
import 'package:inventario/features/empresa/ui/color_list_screen.dart';
import 'package:inventario/features/empresa/ui/moneda_list_screen.dart';
import 'package:inventario/features/empresa/ui/profile_screen.dart';
import 'package:inventario/features/empresa/ui/role_management_screen.dart';
import 'package:inventario/features/empresa/ui/tipo_producto_selection_screen.dart';
import 'package:inventario/features/empresa/ui/unidad_medida_list_screen.dart';
import 'package:inventario/features/empresa/ui/user_management_screen.dart';
import 'package:provider/provider.dart';
import '../logic/empresa_manager.dart';
import 'empresa_form_screen.dart';
import 'empresa_dashboard_screen.dart';
import 'deleted_empresas_screen.dart';
import 'package:inventario/features/empresa/ui/agregar_stock_empresa_screen.dart';

class EmpresaListScreen extends StatefulWidget {
  const EmpresaListScreen({super.key});

  @override
  State<EmpresaListScreen> createState() => _EmpresaListScreenState();
}

class _EmpresaListScreenState extends State<EmpresaListScreen> {
  // Variable para controlar si el Speed Dial está abierto
  bool _isDialOpen = false;

  @override
  void initState() {
    super.initState();

    // Espera a que el widget esté montado antes de cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaManager>().loadEmpresas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración de Empresas')),
      body: Consumer<EmpresaManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          if (manager.empresas.isEmpty) {
            return const Center(child: Text('No hay empresas registradas'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadEmpresas(),
            child: ListView.builder(
              itemCount: manager.empresas.length,
              itemBuilder: (context, index) {
                final empresa = manager.empresas[index];
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
                    title: Text(
                      empresa.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(empresa.direccion),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para agregar stock
                        IconButton(
                          icon: const Icon(Icons.inventory),
                          onPressed: () =>
                              _navigateToAgregarStock(context, empresa),
                          tooltip: 'Agregar stock',
                        ),
                        IconButton(
                          icon: const Icon(Icons.people),
                          onPressed: () => _navigateToUserManagement(context),
                          tooltip: 'Administrar usuarios',
                        ),
                        // Botón para ver tipos de producto
                        IconButton(
                          icon: const Icon(Icons.category),
                          onPressed: () =>
                              _navigateToTipoProductos(context, empresa),
                          tooltip: 'Ver tipos de producto',
                        ),
                        // Menú de opciones
                        PopupMenuButton(
                          onSelected: (value) =>
                              _handleMenuSelection(value, empresa, context),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'dashboard',
                              child: Text('Dashboard'),
                            ),
                            const PopupMenuItem(
                              value: 'asignar_stock',
                              child: Text('Asignar Stock a Tiendas'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _navigateToDashboard(context, empresa),
                  ),
                );
              },
            ),
          );
        },
      ),
      // Reemplazamos el FloatingActionButton con un SpeedDial
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person),
            label: 'Mi perfil',
            onTap: () => _navigateToProfile(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.admin_panel_settings),
            label: 'Gestionar roles',
            onTap: () => _navigateToRoleManagement(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Agregar empresa',
            onTap: () => _navigateToForm(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.delete_outline),
            label: 'Ver empresas eliminadas',
            onTap: () => _navigateToDeleted(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.straighten),
            label: 'Ver unidades de medida',
            onTap: () => _navigateToUnidadesMedida(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.palette),
            label: 'Gestionar colores',
            onTap: () => _navigateToColores(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.people),
            label: 'Administrar usuarios',
            onTap: () => _navigateToUserManagement(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.monetization_on),
            label: 'Gestionar monedas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonedaListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // El resto de los métodos de navegación permanecen igual
  void _navigateToForm(BuildContext context, [Empresa? empresa]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmpresaFormScreen(empresa: empresa),
      ),
    );
  }

  void _navigateToAgregarStock(BuildContext context, Empresa empresa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarStockEmpresaScreen(
          idEmpresa: empresa.id,
          empresaNombre: empresa.nombre,
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, Empresa empresa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmpresaDashboardScreen(empresa: empresa),
      ),
    );
  }

  void _navigateToDeleted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeletedEmpresasScreen()),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManagementScreen()),
    );
  }

  void _navigateToTipoProductos(BuildContext context, Empresa empresa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TipoProductoSelectionScreen(
          idEmpresa: empresa.id,
          empresaNombre: empresa.nombre,
        ),
      ),
    );
  }

  void _navigateToUnidadesMedida(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnidadMedidaListScreen()),
    );
  }

  void _handleMenuSelection(
    String value,
    Empresa empresa,
    BuildContext context,
  ) {
    switch (value) {
      case 'edit':
        _navigateToForm(context, empresa);
        break;
      case 'dashboard':
        _navigateToDashboard(context, empresa);
        break;
      case 'asignar_stock':
        _navigateToAsignarStock(context, empresa);
        break;
      case 'delete':
        _showDeleteConfirmation(context, empresa);
        break;
    }
  }

  void _navigateToAsignarStock(BuildContext context, Empresa empresa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignarStockTiendaScreen(
          empresaId: empresa.id,
          empresaNombre: empresa.nombre,
        ),
      ),
    );
  }

  void _navigateToColores(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ColorListScreen()),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Empresa empresa) {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final String? userId = authManager.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final manager = Provider.of<EmpresaManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${empresa.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await manager.deleteEmpresa(empresa.id, userId);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  // Función para navegar a la pantalla de gestión de roles
  void _navigateToRoleManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoleManagementScreen()),
    );
  }
}
