import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/empresa_model.dart';
import 'package:provider/provider.dart';
import '../logic/empresa_manager.dart';

class DeletedEmpresasScreen extends StatelessWidget {
  const DeletedEmpresasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empresas Eliminadas')),
      body: Consumer<EmpresaManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          if (manager.deletedEmpresas.isEmpty) {
            return const Center(child: Text('No hay empresas eliminadas'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadDeletedEmpresas(),
            child: ListView.builder(
              itemCount: manager.deletedEmpresas.length,
              itemBuilder: (context, index) {
                final empresa = manager.deletedEmpresas[index];
                return ListTile(
                  title: Text(empresa.nombre),
                  subtitle: Text(
                    'Eliminada el: ${empresa.updatedAt.toString()}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () => _showRestoreConfirmation(context, empresa),
                    tooltip: 'Restaurar empresa',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, Empresa empresa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar restauración'),
        content: Text('¿Está seguro de restaurar ${empresa.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<EmpresaManager>(
                context,
                listen: false,
              ).restoreEmpresa(empresa.id);
              Navigator.pop(context);
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
