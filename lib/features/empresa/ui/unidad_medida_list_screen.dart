// lib/features/producto/ui/unidad_medida_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unidad_medida_model.dart';
import '../logic/unidad_medida_manager.dart';
import 'unidad_medida_form_screen.dart';

class UnidadMedidaListScreen extends StatefulWidget {
  const UnidadMedidaListScreen({super.key});

  @override
  State<UnidadMedidaListScreen> createState() => _UnidadMedidaListScreenState();
}

class _UnidadMedidaListScreenState extends State<UnidadMedidaListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar las unidades de medida cuando la pantalla se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnidadMedidaManager>(
        context,
        listen: false,
      ).loadUnidadesMedida();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades de Medida')),
      body: Consumer<UnidadMedidaManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${manager.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => manager.loadUnidadesMedida(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (manager.unidadesMedida.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No hay unidades de medida registradas'),
                  SizedBox(height: 16),
                  Text('Presiona el botón + para agregar una nueva unidad'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadUnidadesMedida(),
            child: ListView.builder(
              itemCount: manager.unidadesMedida.length,
              itemBuilder: (context, index) {
                final unidad = manager.unidadesMedida[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(unidad.nombre),
                    subtitle: Text(unidad.descripcion),
                    trailing: PopupMenuButton(
                      onSelected: (value) =>
                          _handleMenuSelection(value, unidad, context),
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

  void _navigateToForm(BuildContext context, [UnidadMedida? unidad]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnidadMedidaFormScreen(unidad: unidad),
      ),
    ).then((_) {
      // Recargar los datos cuando volvemos del formulario
      Provider.of<UnidadMedidaManager>(
        context,
        listen: false,
      ).loadUnidadesMedida();
    });
  }

  void _handleMenuSelection(
    String value,
    UnidadMedida unidad,
    BuildContext context,
  ) {
    switch (value) {
      case 'edit':
        _navigateToForm(context, unidad);
        break;
      case 'delete':
        _showDeleteConfirmation(context, unidad);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, UnidadMedida unidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${unidad.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<UnidadMedidaManager>(
                context,
                listen: false,
              ).deleteUnidadMedida(unidad.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
