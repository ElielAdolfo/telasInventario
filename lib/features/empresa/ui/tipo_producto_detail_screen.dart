// lib/features/producto/ui/tipo_producto_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/logic/producto_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:inventario/features/empresa/models/producto_model.dart';
import 'package:provider/provider.dart';
import '../models/tipo_producto_model.dart';
import '../logic/tipo_producto_manager.dart';

class TipoProductoDetailScreen extends StatelessWidget {
  final TipoProducto tipoProducto;
  const TipoProductoDetailScreen({super.key, required this.tipoProducto});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ColorManager>(
          create: (_) => ColorManager()..loadColores(),
        ),
        ChangeNotifierProvider<ProductoManager>(
          create: (_) =>
              ProductoManager()..loadProductosByTipo(tipoProducto.id),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(tipoProducto.nombre),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditTipoProductoDialog(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipoProductoInfo(context),
              const SizedBox(height: 24),
              _buildCantidadesSection(context),
              const SizedBox(height: 24),
              _buildPreciosSection(context), // Nueva sección de precios
              const SizedBox(height: 24),
              _buildProductosSection(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddProductoDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTipoProductoInfo(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForTipo(tipoProducto.nombre),
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoProducto.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tipoProducto.cantidadPrioritaria} ${tipoProducto.unidadMedida}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tipoProducto.categoria.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.category, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Categoría: ${tipoProducto.categoria}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (tipoProducto.descripcion != null &&
                tipoProducto.descripcion!.isNotEmpty)
              Text(
                tipoProducto.descripcion!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  tipoProducto.requiereColor ? Icons.check_circle : Icons.block,
                  color: tipoProducto.requiereColor
                      ? Colors.purple
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  tipoProducto.requiereColor
                      ? 'Requiere color'
                      : 'No requiere color',
                  style: TextStyle(
                    color: tipoProducto.requiereColor
                        ? Colors.purple
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  tipoProducto.permiteVentaParcial
                      ? Icons.check_circle
                      : Icons.block,
                  color: tipoProducto.permiteVentaParcial
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  tipoProducto.permiteVentaParcial
                      ? 'Permite venta parcial'
                      : 'Solo venta completa',
                  style: TextStyle(
                    color: tipoProducto.permiteVentaParcial
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Nueva sección para mostrar los precios
  Widget _buildPreciosSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Precios',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrecioItem(
                  context,
                  'Precio Compra',
                  tipoProducto.precioCompraDefault,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildPrecioItem(
                  context,
                  'Precio Venta Menor',
                  tipoProducto.precioVentaDefaultMenor,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildPrecioItem(
                  context,
                  'Precio Venta Mayor',
                  tipoProducto.precioVentaDefaultMayor,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrecioItem(
    BuildContext context,
    String label,
    double price,
    Color color,
  ) {
    return Row(
      children: [
        Text('$label:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Bs. ${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCantidadesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidades Disponibles',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cantidad Prioritaria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tipoProducto.cantidadPrioritaria} ${tipoProducto.unidadMedida}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Todas las Cantidades Posibles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tipoProducto.cantidadesPosibles.map((cantidad) {
                    final isPrioritaria =
                        cantidad == tipoProducto.cantidadPrioritaria;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPrioritaria
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$cantidad ${tipoProducto.unidadMedida}',
                        style: TextStyle(
                          color: isPrioritaria ? Colors.white : Colors.black,
                          fontWeight: isPrioritaria
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductosSection(BuildContext context) {
    return Consumer2<ProductoManager, ColorManager>(
      builder: (context, productoManager, colorManager, child) {
        if (productoManager.isLoading || colorManager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (productoManager.error != null || colorManager.error != null) {
          return Center(
            child: Text(
              'Error: ${productoManager.error ?? colorManager.error}',
            ),
          );
        }
        if (productoManager.productos.isEmpty) {
          return const Center(
            child: Text('No hay productos registrados para este tipo'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos Disponibles',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${productoManager.productos.length} productos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productoManager.productos.length,
              itemBuilder: (context, index) {
                return null;

                /*final producto = productoManager.productos[index];
                final color = colorManager.colores.firstWhere(
                  (c) => c.id == producto.idColor,
                  orElse: () => ColorProducto(
                    id: '',
                    nombre: 'Desconocido',
                    codigoHex: '#000000',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                return _buildProductoCard(context, producto, color);*/
              },
            ),
          ],
        );
      },
    );
  }

  /*  Widget _buildProductoCard(
    BuildContext context,
    Producto producto,
    ColorProducto color,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(color.codigoHex.replaceFirst('#', '0xFF'))),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(producto.nombre),
        subtitle: Text(color.nombre),
        trailing: PopupMenuButton(
          onSelected: (value) => _handleMenuSelection(value, producto, context),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
*/

  void _handleMenuSelection(
    String value,
    Producto producto,
    BuildContext context,
  ) {
    switch (value) {
      case 'edit':
        _showEditProductoDialog(context, producto);
        break;
      case 'delete':
        _showDeleteConfirmation(context, producto);
        break;
    }
  }

  void _showEditTipoProductoDialog(BuildContext context) {
    final nombreController = TextEditingController(text: tipoProducto.nombre);
    final descripcionController = TextEditingController(
      text: tipoProducto.descripcion ?? '',
    );
    final unidadMedidaController = TextEditingController(
      text: tipoProducto.unidadMedida,
    );
    List<double> cantidadesPosibles = List.from(
      tipoProducto.cantidadesPosibles,
    );
    double cantidadPrioritaria = tipoProducto.cantidadPrioritaria;

    // Controladores para los tres tipos de precios
    final precioCompraController = TextEditingController(
      text: tipoProducto.precioCompraDefault.toString(),
    );
    final precioVentaMenorController = TextEditingController(
      text: tipoProducto.precioVentaDefaultMenor.toString(),
    );
    final precioVentaMayorController = TextEditingController(
      text: tipoProducto.precioVentaDefaultMayor.toString(),
    );

    final categoriaController = TextEditingController(
      text: tipoProducto.categoria,
    );
    bool requiereColor = tipoProducto.requiereColor;
    bool permiteVentaParcial = tipoProducto.permiteVentaParcial;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Tipo de Producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: unidadMedidaController,
                    decoration: const InputDecoration(
                      labelText: 'Unidad de Medida',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cantidades Posibles:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: cantidadesPosibles.map((cantidad) {
                      return InputChip(
                        label: Text('$cantidad'),
                        onPressed: () {
                          setState(() {
                            cantidadPrioritaria = cantidad;
                          });
                        },
                        selected: cantidadPrioritaria == cantidad,
                        selectedColor: Theme.of(context).primaryColor,
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            if (cantidadesPosibles.length > 1) {
                              cantidadesPosibles.remove(cantidad);
                              if (cantidadPrioritaria == cantidad) {
                                cantidadPrioritaria = cantidadesPosibles.first;
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Agregar cantidad',
                            hintText: 'Ej: 6, 9',
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              final nuevaCantidad = double.tryParse(value);
                              if (nuevaCantidad != null &&
                                  !cantidadesPosibles.contains(nuevaCantidad)) {
                                setState(() {
                                  cantidadesPosibles.add(nuevaCantidad);
                                });
                              }
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final controller = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Agregar Cantidad'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final nuevaCantidad = double.tryParse(
                                      controller.text,
                                    );
                                    if (nuevaCantidad != null &&
                                        !cantidadesPosibles.contains(
                                          nuevaCantidad,
                                        )) {
                                      setState(() {
                                        cantidadesPosibles.add(nuevaCantidad);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Agregar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cantidad Prioritaria: $cantidadPrioritaria',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sección de precios
                  const Text(
                    'Precios',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: precioCompraController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Compra',
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: precioVentaMenorController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Venta Menor',
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: precioVentaMayorController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Venta Mayor',
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: categoriaController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Requiere Color'),
                    subtitle: const Text(
                      'Indica si el producto necesita selección de color',
                    ),
                    value: requiereColor,
                    onChanged: (value) {
                      setState(() {
                        requiereColor = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Permite Venta Parcial'),
                    subtitle: const Text(
                      'Permite vender por unidades o solo completo',
                    ),
                    value: permiteVentaParcial,
                    onChanged: (value) {
                      setState(() {
                        permiteVentaParcial = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (nombreController.text.isNotEmpty &&
                      unidadMedidaController.text.isNotEmpty &&
                      cantidadesPosibles.isNotEmpty &&
                      precioCompraController.text.isNotEmpty &&
                      precioVentaMenorController.text.isNotEmpty &&
                      precioVentaMayorController.text.isNotEmpty) {
                    final tipoActualizado = tipoProducto.copyWith(
                      nombre: nombreController.text,
                      descripcion: descripcionController.text.isNotEmpty
                          ? descripcionController.text
                          : null,
                      unidadMedida: unidadMedidaController.text,
                      cantidadesPosibles: cantidadesPosibles,
                      cantidadPrioritaria: cantidadPrioritaria,
                      precioCompraDefault: double.parse(
                        precioCompraController.text,
                      ),
                      precioVentaDefaultMenor: double.parse(
                        precioVentaMenorController.text,
                      ),
                      precioVentaDefaultMayor: double.parse(
                        precioVentaMayorController.text,
                      ),
                      categoria: categoriaController.text,
                      requiereColor: requiereColor,
                      permiteVentaParcial: permiteVentaParcial,
                    );

                    Navigator.pop(context);
                    await Provider.of<TipoProductoManager>(
                      context,
                      listen: false,
                    ).updateTipoProducto(tipoActualizado);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddProductoDialog(BuildContext context) {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(
          idTipoProducto: tipoProducto.id,
          tipoProductoNombre: tipoProducto.nombre,
          requiereColor: tipoProducto.requiereColor,
        ),
      ),
    );*/
  }

  void _showEditProductoDialog(BuildContext context, Producto producto) {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(
          idTipoProducto: tipoProducto.id,
          tipoProductoNombre: tipoProducto.nombre,
          requiereColor: tipoProducto.requiereColor,
          producto: producto,
        ),
      ),
    );*/
  }

  void _showDeleteConfirmation(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${producto.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<ProductoManager>(
                context,
                listen: false,
              ).deleteProducto(producto.id, producto.idTipoProducto);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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
}
