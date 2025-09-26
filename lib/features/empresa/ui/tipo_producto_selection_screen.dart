// lib/features/producto/ui/tipo_producto_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/ui/unidad_medida_list_screen.dart';
import 'package:provider/provider.dart';
import '../models/tipo_producto_model.dart';
import '../models/unidad_medida_model.dart';
import '../logic/tipo_producto_manager.dart';
import '../logic/unidad_medida_manager.dart';
import 'tipo_producto_detail_screen.dart';
import 'categoria_productos_screen.dart';
import '../../empresa/ui/empresa_list_screen.dart';

class TipoProductoSelectionScreen extends StatefulWidget {
  final String? idEmpresa;
  final String? empresaNombre;
  const TipoProductoSelectionScreen({
    Key? key,
    this.idEmpresa,
    this.empresaNombre,
  }) : super(key: key);

  @override
  State<TipoProductoSelectionScreen> createState() =>
      _TipoProductoSelectionScreenState();
}

class _TipoProductoSelectionScreenState
    extends State<TipoProductoSelectionScreen> {
  // Guardar una referencia al manager para evitar problemas de contexto
  late TipoProductoManager _tipoProductoManager;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnidadMedidaManager>(
        context,
        listen: false,
      ).loadUnidadesMedida();
      // Cargar tipos de producto por empresa si se proporciona idEmpresa
      if (widget.idEmpresa != null) {
        Provider.of<TipoProductoManager>(
          context,
          listen: false,
        ).loadTiposProductoByEmpresa(widget.idEmpresa!);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tipoProductoManager = Provider.of<TipoProductoManager>(
        context,
        listen: false,
      );
      // Cargar tipos de producto por empresa si se proporciona idEmpresa
      if (widget.idEmpresa != null) {
        _tipoProductoManager.loadTiposProductoByEmpresa(widget.idEmpresa!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TipoProductoManager>(
          create: (_) => TipoProductoManager(),
        ),
        ChangeNotifierProvider<UnidadMedidaManager>(
          create: (_) => UnidadMedidaManager(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.empresaNombre != null
                ? 'Tipos de Producto - ${widget.empresaNombre}'
                : 'Tipos de Productos',
          ),
          actions: [
            if (widget.idEmpresa == null)
              IconButton(
                icon: const Icon(Icons.business),
                onPressed: () => _navigateToEmpresas(context),
                tooltip: 'Ir a Empresas',
              ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => _navigateToCategorias(context),
              tooltip: 'Ver Categorías',
            ),
          ],
        ),
        body: Consumer2<TipoProductoManager, UnidadMedidaManager>(
          builder: (context, tipoProductoManager, unidadMedidaManager, child) {
            // Actualizar las referencias a los managers
            _tipoProductoManager = tipoProductoManager;
            unidadMedidaManager = unidadMedidaManager;
            // Cargar tipos de producto por empresa si se proporciona idEmpresa
            if (widget.idEmpresa != null &&
                tipoProductoManager.tiposProducto.isEmpty &&
                !tipoProductoManager.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                tipoProductoManager.loadTiposProductoByEmpresa(
                  widget.idEmpresa!,
                );
              });
            }
            if (tipoProductoManager.isLoading ||
                unidadMedidaManager.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (tipoProductoManager.error != null ||
                unidadMedidaManager.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${tipoProductoManager.error ?? unidadMedidaManager.error}',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.idEmpresa != null) {
                          tipoProductoManager.loadTiposProductoByEmpresa(
                            widget.idEmpresa!,
                          );
                        }
                        unidadMedidaManager.loadUnidadesMedida();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (tipoProductoManager.tiposProducto.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No hay tipos de productos registrados'),
                    SizedBox(height: 16),
                    Text('Presiona el botón + para agregar una nueva unidad'),
                  ],
                ),
              );
            }
            // Agrupar por categorías
            final categorias = tipoProductoManager.getCategoriasUnicas();
            return RefreshIndicator(
              onRefresh: () async {
                if (widget.idEmpresa != null) {
                  await tipoProductoManager.loadTiposProductoByEmpresa(
                    widget.idEmpresa!,
                  );
                }
                await unidadMedidaManager.loadUnidadesMedida();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    categorias.length + 1, // +1 para la sección "Sin categoría"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Mostrar productos sin categoría
                    final productosSinCategoria = tipoProductoManager
                        .tiposProducto
                        .where((p) => p.categoria.isEmpty)
                        .toList();
                    if (productosSinCategoria.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _buildCategoriaSection(
                      context,
                      'Sin categoría',
                      productosSinCategoria,
                    );
                  }
                  final categoria = categorias[index - 1];
                  final productosDeCategoria = tipoProductoManager.tiposProducto
                      .where((p) => p.categoria == categoria)
                      .toList();
                  return _buildCategoriaSection(
                    context,
                    categoria,
                    productosDeCategoria,
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTipoProductoDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoriaSection(
    BuildContext context,
    String categoria,
    List<TipoProducto> productos,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            categoria,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final tipo = productos[index];
            return _buildTipoProductoCard(context, tipo);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTipoProductoCard(BuildContext context, TipoProducto tipo) {
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
              Text(
                'Compra: Bs. ${tipo.precioCompraDefault.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Venta: Bs. ${tipo.precioVentaDefaultMenor.toStringAsFixed(2)} - ${tipo.precioVentaDefaultMayor.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              if (tipo.requiereColor && tipo.codigoColor != null) ...[
                Text(
                  'Código: ${tipo.codigoColor}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (tipo.permiteVentaParcial &&
                  tipo.unidadMedidaSecundaria != null) ...[
                Text(
                  'Unidad secundaria: ${tipo.unidadMedidaSecundaria}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
              ],
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
    ).then((_) {
      // Recargar los datos cuando volvemos de la pantalla de detalle
      if (widget.idEmpresa != null) {
        _tipoProductoManager.loadTiposProductoByEmpresa(widget.idEmpresa!);
      }
    });
  }

  void _navigateToEmpresas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmpresaListScreen()),
    );
  }

  void _navigateToCategorias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaProductosScreen(
          idEmpresa: widget.idEmpresa,
          empresaNombre: widget.empresaNombre,
        ),
      ),
    );
  }

  void _showAddTipoProductoDialog(BuildContext context) {
    if (widget.idEmpresa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una empresa primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final unidadMedidaManager = Provider.of<UnidadMedidaManager>(
      context,
      listen: false,
    );
    // Verificar si hay unidades de medida cargadas, si no, cargarlas
    if (unidadMedidaManager.unidadesMedida.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unidades de Medida'),
          content: const Text(
            'No hay unidades de medida disponibles. ¿Desea agregar algunas ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnidadMedidaListScreen(),
                  ),
                ).then((_) {
                  // Recargar las unidades de medida cuando volvemos
                  unidadMedidaManager.loadUnidadesMedida();
                  // Volver a mostrar el diálogo después de cargar las unidades
                  if (unidadMedidaManager.unidadesMedida.isNotEmpty) {
                    _showAddTipoProductoDialogWithUnidades(
                      context,
                      unidadMedidaManager,
                    );
                  }
                });
              },
              child: const Text('Agregar Unidades'),
            ),
          ],
        ),
      );
    } else {
      _showAddTipoProductoDialogWithUnidades(context, unidadMedidaManager);
    }
  }

  void _showAddTipoProductoDialogWithUnidades(
    BuildContext context,
    UnidadMedidaManager unidadMedidaManager,
  ) {
    final formKey = GlobalKey<FormState>(); // Clave global para el formulario
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    List<int> cantidadesPosibles = [50, 70, 100];
    int cantidadPrioritaria = 50;
    final precioCompraDefaultController = TextEditingController();
    final precioVentaDefaultMenorController = TextEditingController();
    final precioVentaDefaultMayorController = TextEditingController();
    final categoriaController = TextEditingController();
    bool requiereColor = true;
    bool permiteVentaParcial = true;
    String? codigoColor;
    bool tieneDescripcion = false;
    String? unidadMedidaSeleccionada =
        unidadMedidaManager.unidadesMedida.isNotEmpty
        ? unidadMedidaManager.unidadesMedida.first.nombre
        : null;
    String? unidadMedidaSecundaria;

    final tipoProductoManager = Provider.of<TipoProductoManager>(
      context,
      listen: false,
    );
    final List<String> categoriasExistentes = tipoProductoManager
        .getCategoriasUnicas();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Nuevo Tipo de Producto'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey, // Asignamos la clave al formulario
                child: Consumer<UnidadMedidaManager>(
                  builder: (context, unidadMedidaManager, child) {
                    if (unidadMedidaManager.unidadesMedida.isEmpty) {
                      return Column(
                        children: [
                          Text('No hay unidades de medida disponibles'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UnidadMedidaListScreen(),
                                ),
                              );
                            },
                            child: const Text('Agregar Unidades de Medida'),
                          ),
                        ],
                      );
                    }

                    final List<String> categoriasExistentes =
                        tipoProductoManager.getCategoriasUnicas();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo Nombre con validaciones
                        TextFormField(
                          controller: nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            hintText: 'Ej: Piel de Sirena',
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          maxLength: 30,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (value.trim().length > 30) {
                              return 'Máximo 30 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          title: const Text('Incluir descripción'),
                          value: tieneDescripcion,
                          onChanged: (value) {
                            setState(() {
                              tieneDescripcion = value;
                            });
                          },
                        ),

                        if (tieneDescripcion) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              hintText: 'Descripción del tipo de producto',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (tieneDescripcion &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Ingrese la descripción';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 8),

                        // Selector de unidad de medida
                        DropdownButtonFormField<String>(
                          value: unidadMedidaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Unidad de Medida',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          items: unidadMedidaManager.unidadesMedida.map((
                            unidad,
                          ) {
                            return DropdownMenuItem<String>(
                              value: unidad.nombre,
                              child: Text(unidad.nombre),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              unidadMedidaSeleccionada = value;
                              if (unidadMedidaSecundaria ==
                                  unidadMedidaSeleccionada) {
                                unidadMedidaSecundaria = null;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione una unidad de medida';
                            }
                            return null;
                          },
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
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Agregar cantidad',
                                  hintText: 'Ej: 6, 9',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final num = int.tryParse(value);
                                    if (num == null) {
                                      return 'Debe ser un número entero';
                                    }
                                    if (cantidadesPosibles.contains(num)) {
                                      return 'Esta cantidad ya existe';
                                    }
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final nuevaCantidad = int.tryParse(value);
                                    if (nuevaCantidad != null &&
                                        !cantidadesPosibles.contains(
                                          nuevaCantidad,
                                        )) {
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
                                  context: dialogContext,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Agregar Cantidad'),
                                    content: TextFormField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Cantidad',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese una cantidad';
                                        }
                                        final num = int.tryParse(value);
                                        if (num == null) {
                                          return 'Debe ser un número entero';
                                        }
                                        if (cantidadesPosibles.contains(num)) {
                                          return 'Esta cantidad ya existe';
                                        }
                                        return null;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (controller.text.isNotEmpty) {
                                            final nuevaCantidad = int.tryParse(
                                              controller.text,
                                            );
                                            if (nuevaCantidad != null &&
                                                !cantidadesPosibles.contains(
                                                  nuevaCantidad,
                                                )) {
                                              setState(() {
                                                cantidadesPosibles.add(
                                                  nuevaCantidad,
                                                );
                                              });
                                            }
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
                        const SizedBox(height: 8),

                        // Campo Precio de Compra con validaciones
                        TextFormField(
                          controller: precioCompraDefaultController,
                          decoration: const InputDecoration(
                            labelText: 'Precio de Compra por Defecto',
                            hintText: 'Ej: 150.00',
                            prefixIcon: Icon(Icons.money_off),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El precio es obligatorio';
                            }
                            final num = double.tryParse(value);
                            if (num == null) {
                              return 'Debe ser un número válido';
                            }
                            if (value.contains('.') &&
                                value.split('.')[1].length > 2) {
                              return 'Máximo 2 decimales';
                            }
                            if (num <= 0) {
                              return 'Debe ser mayor que cero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Campo Precio Venta Menor con validaciones
                        TextFormField(
                          controller: precioVentaDefaultMenorController,
                          decoration: const InputDecoration(
                            labelText: 'Precio de Venta por Defecto (Menor)',
                            hintText: 'Ej: 170.00',
                            prefixIcon: Icon(Icons.trending_down),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El precio es obligatorio';
                            }
                            final num = double.tryParse(value);
                            if (num == null) {
                              return 'Debe ser un número válido';
                            }
                            if (value.contains('.') &&
                                value.split('.')[1].length > 2) {
                              return 'Máximo 2 decimales';
                            }
                            if (num <= 0) {
                              return 'Debe ser mayor que cero';
                            }
                            final compra = double.tryParse(
                              precioCompraDefaultController.text,
                            );
                            if (compra != null && num <= compra) {
                              return 'Debe ser mayor al precio de compra';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Campo Precio Venta Mayor con validaciones
                        TextFormField(
                          controller: precioVentaDefaultMayorController,
                          decoration: const InputDecoration(
                            labelText: 'Precio de Venta por Defecto (Mayor)',
                            hintText: 'Ej: 190.00',
                            prefixIcon: Icon(Icons.trending_up),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El precio es obligatorio';
                            }
                            final num = double.tryParse(value);
                            if (num == null) {
                              return 'Debe ser un número válido';
                            }
                            if (value.contains('.') &&
                                value.split('.')[1].length > 2) {
                              return 'Máximo 2 decimales';
                            }
                            if (num <= 0) {
                              return 'Debe ser mayor que cero';
                            }
                            final menor = double.tryParse(
                              precioVentaDefaultMenorController.text,
                            );
                            if (menor != null && num <= menor) {
                              return 'Debe ser mayor al precio menor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Campo Categoría con Autocomplete y validaciones
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return categoriasExistentes.where((String option) {
                              return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            categoriaController.text = selection;
                          },
                          fieldViewBuilder:
                              (
                                BuildContext context,
                                TextEditingController
                                fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                fieldTextEditingController.text =
                                    categoriaController.text;

                                categoriaController.addListener(() {
                                  fieldTextEditingController.text =
                                      categoriaController.text;
                                });

                                return TextFormField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoría',
                                    hintText:
                                        'Ej: Telas, Accesorios, Herramientas',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category),
                                    counterText: '',
                                  ),
                                  maxLength: 30,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'La categoría es obligatoria';
                                    }
                                    if (value.trim().length > 30) {
                                      return 'Máximo 30 caracteres';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    final formattedValue = value
                                        .toUpperCase()
                                        .trim();

                                    if (formattedValue != value) {
                                      //categoriaController.text = formattedValue;
                                      // categoriaController.selection =
                                      //     TextSelection.fromPosition(
                                      //       TextPosition(
                                      //         offset: formattedValue.length,
                                      //       ),
                                      //     );
                                    }
                                  },
                                );
                              },
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
                              if (!requiereColor) {
                                codigoColor = null;
                              }
                            });
                          },
                        ),

                        if (requiereColor) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Código de Color',
                              hintText: '4 dígitos o letras',
                              counterText: '',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.format_color_fill),
                            ),
                            maxLength: 4,
                            validator: (value) {
                              if (requiereColor &&
                                  (value == null || value.isEmpty)) {
                                return 'El código de color es obligatorio';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Convertir a mayúsculas y eliminar espacios
                              final formattedValue = value.toUpperCase().trim();
                              if (formattedValue != value) {
                                codigoColor = formattedValue;
                              } else {
                                codigoColor = value;
                              }
                            },
                          ),
                        ],

                        SwitchListTile(
                          title: const Text('Permite Venta Parcial'),
                          subtitle: const Text(
                            'Permite vender por unidades o solo completo',
                          ),
                          value: permiteVentaParcial,
                          onChanged: (value) {
                            setState(() {
                              permiteVentaParcial = value;
                              if (!permiteVentaParcial) {
                                unidadMedidaSecundaria = null;
                              }
                            });
                          },
                        ),

                        if (permiteVentaParcial) ...[
                          DropdownButtonFormField<String>(
                            value: unidadMedidaSecundaria,
                            decoration: const InputDecoration(
                              labelText: 'Unidad de Medida Secundaria',
                              border: OutlineInputBorder(),
                            ),
                            items: unidadMedidaManager.unidadesMedida
                                .where(
                                  (u) => u.nombre != unidadMedidaSeleccionada,
                                )
                                .map((unidad) {
                                  return DropdownMenuItem<String>(
                                    value: unidad.nombre,
                                    child: Text(unidad.nombre),
                                  );
                                })
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                unidadMedidaSecundaria = value;
                              });
                            },
                            validator: (value) {
                              if (permiteVentaParcial &&
                                  (value == null || value.isEmpty)) {
                                return 'Seleccione una unidad de medida diferente';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  // Validar el formulario antes de guardar
                  if (formKey.currentState!.validate()) {
                    // Validar descripción si el checkbox está marcado
                    if (tieneDescripcion &&
                        descripcionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese la descripción'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validar código de color si requiere color
                    if (requiereColor &&
                        (codigoColor == null || codigoColor!.isEmpty)) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese el código de color'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validar unidad secundaria si permite venta parcial
                    if (permiteVentaParcial &&
                        (unidadMedidaSecundaria == null ||
                            unidadMedidaSecundaria!.isEmpty)) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Seleccione una unidad de medida secundaria',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final tipoProductoManager =
                        Provider.of<TipoProductoManager>(
                          context,
                          listen: false,
                        );

                    final nuevoTipo = TipoProducto(
                      id: '',
                      idEmpresa: widget.idEmpresa!,
                      nombre: nombreController.text.trim(),
                      descripcion: tieneDescripcion
                          ? descripcionController.text.trim()
                          : null,
                      unidadMedida: unidadMedidaSeleccionada!,
                      cantidadesPosibles: cantidadesPosibles,
                      cantidadPrioritaria: cantidadPrioritaria,
                      precioCompraDefault: double.parse(
                        precioCompraDefaultController.text,
                      ),
                      precioVentaDefaultMenor: double.parse(
                        precioVentaDefaultMenorController.text,
                      ),
                      precioVentaDefaultMayor: double.parse(
                        precioVentaDefaultMayorController.text,
                      ),
                      requiereColor: requiereColor,
                      codigoColor: requiereColor
                          ? codigoColor?.toUpperCase().trim()
                          : null,
                      categoria: categoriaController.text.toUpperCase().trim(),
                      permiteVentaParcial: permiteVentaParcial,
                      unidadMedidaSecundaria: permiteVentaParcial
                          ? unidadMedidaSecundaria
                          : null,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    Navigator.pop(dialogContext);
                    await _tipoProductoManager.addTipoProducto(nuevoTipo);
                    _tipoProductoManager.notifyListeners();
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
}
