// lib/features/color/ui/color_list_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:provider/provider.dart';
import 'color_form_screen.dart';

class ColorListScreen extends StatefulWidget {
  const ColorListScreen({Key? key}) : super(key: key);

  @override
  State<ColorListScreen> createState() => _ColorListScreenState();
}

class _ColorListScreenState extends State<ColorListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los colores al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ColorManager>(context, listen: false).loadColores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Colores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToForm(context),
          ),
        ],
      ),
      body: Consumer<ColorManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }

          if (manager.colores.isEmpty) {
            return const Center(child: Text('No hay colores registrados'));
          }

          return RefreshIndicator(
            onRefresh: () async => await manager.loadColores(),
            child: ListView.builder(
              itemCount: manager.colores.length,
              itemBuilder: (context, index) {
                final color = manager.colores[index];
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
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color.codigoColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    title: Text(color.nombreColor),
                    subtitle: Text(color.codigoColor),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToForm(context, color),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmation(context, color),
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

  Color _parseColor(String hexColor) {
    try {
      // Eliminar el # si existe
      hexColor = hexColor.replaceAll('#', '');
      // Convertir a un valor de color válido
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey; // Color por defecto si hay un error
    }
  }

  void _navigateToForm(BuildContext context, [ColorProducto? color]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ColorFormScreen(color: color)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ColorProducto color) {
    final manager = Provider.of<ColorManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar el color ${color.nombreColor}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await manager.deleteColor(color.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
