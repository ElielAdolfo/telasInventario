// lib/features/empresa/ui/tienda_list_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/ui/reporte_screen.dart';
import 'package:inventario/features/empresa/ui/tienda_solicitudes_screen.dart';
import 'package:inventario/features/empresa/ui/venta_screen.dart'; // Importar la nueva pantalla
import 'package:provider/provider.dart';
import '../models/tienda_model.dart';
import '../logic/tienda_manager.dart';
import 'tienda_form_screen.dart';

class TiendaListScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  const TiendaListScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<TiendaListScreen> createState() => _TiendaListScreenState();
}

class _TiendaListScreenState extends State<TiendaListScreen> {
  bool _hasChanges = false; // Variable para rastrear cambios

  @override
  void initState() {
    super.initState();

    // Cargar tiendas
    Future.microtask(() {
      context.read<TiendaManager>().loadTiendasByEmpresa(widget.empresaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Tiendas de ${widget.empresaNombre}')),
        body: _buildTiendasList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToForm(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTiendasList() {
    return Consumer<TiendaManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (manager.error != null) {
          return Center(child: Text('Error: ${manager.error}'));
        }
        if (manager.tiendas.isEmpty) {
          return const Center(child: Text('No hay tiendas registradas'));
        }
        return RefreshIndicator(
          onRefresh: () async =>
              await manager.loadTiendasByEmpresa(widget.empresaId),
          child: ListView.builder(
            itemCount: manager.tiendas.length,
            itemBuilder: (context, index) {
              final tienda = manager.tiendas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        tienda.isWarehouse ? Icons.warehouse : Icons.store,
                        color: tienda.isWarehouse ? Colors.brown : Colors.blue,
                        size: 32,
                      ),
                      title: Text(
                        tienda.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(tienda.direccion),
                      trailing: PopupMenuButton(
                        onSelected: (value) =>
                            _handleMenuSelection(value, tienda, context),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.request_page,
                            label: 'Solicitudes',
                            color: Colors.blue,
                            onPressed: () => _verSolicitudes(context, tienda),
                          ),
                          _buildActionButton(
                            icon: Icons.point_of_sale,
                            label: 'Vender',
                            color: Colors.green,
                            onPressed: () => _venderProductos(context, tienda),
                          ),
                          _buildActionButton(
                            icon: Icons.assessment,
                            label: 'Reportes',
                            color: Colors.purple,
                            onPressed: () => _verReportes(context, tienda),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verSolicitudes(BuildContext context, Tienda tienda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TiendaSolicitudesScreen(
          tienda: tienda,
          empresaId: widget.empresaId,
        ),
      ),
    );
  }

  void _venderProductos(BuildContext context, Tienda tienda) {
    // Navegar a la pantalla de venta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VentaScreen(empresaId: widget.empresaId, tienda: tienda),
      ),
    );
  }

  void _verReportes(BuildContext context, Tienda tienda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReporteScreen(empresaId: widget.empresaId, tienda: tienda),
      ),
    );
  }

  void _navigateToForm(BuildContext context, [Tienda? tienda]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TiendaFormScreen(empresaId: widget.empresaId, tienda: tienda),
      ),
    );
    if (result == true) {
      _hasChanges = true; // Marcar que hubo cambios
      await context.read<TiendaManager>().loadTiendasByEmpresa(
        widget.empresaId,
      );
    }
  }

  void _handleMenuSelection(String value, Tienda tienda, BuildContext context) {
    switch (value) {
      case 'edit':
        _navigateToForm(context, tienda);
        break;
      case 'delete':
        _showDeleteConfirmation(context, tienda);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Tienda tienda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${tienda.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<TiendaManager>().deleteTienda(
                  tienda.id,
                  tienda.empresaId,
                );
                _hasChanges = true; // Marcar que hubo cambios
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
