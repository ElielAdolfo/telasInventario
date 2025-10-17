// lib/features/moneda/ui/moneda_list_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/moneda_manager.dart';
import 'package:inventario/features/empresa/models/moneda_model.dart';
import 'package:inventario/features/empresa/ui/moneda_form_screen.dart';
import 'package:provider/provider.dart';

class MonedaListScreen extends StatefulWidget {
  const MonedaListScreen({super.key});

  @override
  State<MonedaListScreen> createState() => _MonedaListScreenState();
}

class _MonedaListScreenState extends State<MonedaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonedaManager>().loadMonedas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración de Monedas')),
      body: Consumer<MonedaManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          if (manager.monedas.isEmpty) {
            return const Center(child: Text('No hay monedas registradas'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadMonedas(),
            child: ListView.builder(
              itemCount: manager.monedas.length,
              itemBuilder: (context, index) {
                final moneda = manager.monedas[index];
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
                      moneda.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${moneda.codigo} - ${moneda.simbolo}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (moneda.principal)
                          const Icon(Icons.star, color: Colors.amber),
                        PopupMenuButton(
                          onSelected: (value) =>
                              _handleMenuSelection(value, moneda, context),
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
                      ],
                    ),
                    onTap: () => _navigateToForm(context, moneda),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm(BuildContext context, [Moneda? moneda]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonedaFormScreen(moneda: moneda)),
    );
  }

  void _handleMenuSelection(String value, Moneda moneda, BuildContext context) {
    switch (value) {
      case 'edit':
        _navigateToForm(context, moneda);
        break;
      case 'delete':
        _showDeleteConfirmation(context, moneda);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Moneda moneda) {
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

    final manager = Provider.of<MonedaManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${moneda.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await manager.deleteMoneda(moneda.id, userId);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
