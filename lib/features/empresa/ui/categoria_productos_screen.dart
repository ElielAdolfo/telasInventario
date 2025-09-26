// lib/features/producto/ui/categoria_productos_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/ui/tipo_producto_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/tipo_producto_model.dart';
import '../logic/tipo_producto_manager.dart';

class CategoriaProductosScreen extends StatelessWidget {
  final String? idEmpresa;
  final String? empresaNombre;
  const CategoriaProductosScreen({Key? key, this.idEmpresa, this.empresaNombre})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          empresaNombre != null
              ? 'Categorías - $empresaNombre'
              : 'Categorías de Productos',
        ),
      ),
      body: Consumer<TipoProductoManager>(
        builder: (context, manager, child) {
          // Cargar tipos de producto por empresa si se proporciona idEmpresa
          if (idEmpresa != null &&
              manager.tiposProducto.isEmpty &&
              !manager.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              manager.loadTiposProductoByEmpresa(idEmpresa!);
            });
          }
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (manager.error != null) {
            return Center(child: Text('Error: ${manager.error}'));
          }
          final categorias = manager.getCategoriasUnicas();
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles'));
          }
          return RefreshIndicator(
            onRefresh: () async =>
                await manager.loadTiposProductoByEmpresa(idEmpresa ?? ''),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return _buildCategoriaCard(context, categoria, manager);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriaCard(
    BuildContext context,
    String categoria,
    TipoProductoManager manager,
  ) {
    // Obtener productos de esta categoría
    final productos = manager.tiposProducto
        .where((p) => p.categoria == categoria)
        .toList();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToCategoriaDetail(context, categoria, productos),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.category,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                categoria,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${productos.length} productos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategoriaDetail(
    BuildContext context,
    String categoria,
    List<TipoProducto> productos,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaDetailScreen(
          idEmpresa: idEmpresa,
          empresaNombre: empresaNombre,
          categoria: categoria,
          productos: productos,
        ),
      ),
    );
  }
}

class CategoriaDetailScreen extends StatelessWidget {
  final String? idEmpresa;
  final String? empresaNombre;
  final String categoria;
  final List<TipoProducto> productos;
  const CategoriaDetailScreen({
    Key? key,
    this.idEmpresa,
    this.empresaNombre,
    required this.categoria,
    required this.productos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          empresaNombre != null
              ? '$categoria - $empresaNombre'
              : 'Categoría: $categoria',
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final tipo = productos[index];
          return _buildProductoCard(context, tipo);
        },
      ),
    );
  }

  Widget _buildProductoCard(BuildContext context, TipoProducto tipo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToTipoProductoDetail(context, tipo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    _getIconForTipo(tipo.nombre),
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tipo.nombre,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${tipo.cantidadPrioritaria} ${tipo.unidadMedida} (prioritario)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Opciones: ${tipo.cantidadesPosibles.join(", ")} ${tipo.unidadMedida}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              // Corregido: usar precioVentaDefaultMenor en lugar de precioDefault
              Text(
                'Bs. ${tipo.precioVentaDefaultMenor.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (tipo.requiereColor)
                    const Icon(Icons.palette, size: 16, color: Colors.purple),
                  if (tipo.permiteVentaParcial)
                    const Icon(Icons.content_cut, size: 16, color: Colors.blue),
                  if (!tipo.permiteVentaParcial)
                    const Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTipo(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'piel de sirena':
        return Icons.texture;
      case 'hilos':
        return Icons.line_style;
      case 'perlas':
        return Icons.grain;
      case 'tela':
        return Icons.dashboard;
      case 'motor':
        return Icons.settings;
      case 'herramienta':
        return Icons.build;
      default:
        return Icons.category;
    }
  }

  void _navigateToTipoProductoDetail(BuildContext context, TipoProducto tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TipoProductoDetailScreen(tipoProducto: tipo),
      ),
    );
  }
}
