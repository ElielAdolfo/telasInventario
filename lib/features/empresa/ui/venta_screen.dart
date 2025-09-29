// lib/features/empresa/ui/venta_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/carrito_item_model.dart';
import 'package:provider/provider.dart';
import '../logic/venta_producto_manager.dart';
import '../logic/carrito_manager.dart';
import '../models/stock_tienda_model.dart';
import '../models/stock_lote_tienda_model.dart';
import '../models/stock_unidad_abierta_model.dart';
import 'carrito_screen.dart';
import '../models/tienda_model.dart';

class VentaScreen extends StatelessWidget {
  final String empresaId;
  final Tienda tienda;

  const VentaScreen({Key? key, required this.empresaId, required this.tienda})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VentaProductoManager()),
        ChangeNotifierProvider(create: (_) => CarritoManager()),
      ],
      child: _VentaScreenContent(empresaId: empresaId, tienda: tienda),
    );
  }
}

class _VentaScreenContent extends StatefulWidget {
  final String empresaId;
  final Tienda tienda;

  const _VentaScreenContent({
    Key? key,
    required this.empresaId,
    required this.tienda,
  }) : super(key: key);

  @override
  __VentaScreenContentState createState() => __VentaScreenContentState();
}

class __VentaScreenContentState extends State<_VentaScreenContent> {
  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentaProductoManager>().cargarDatosIniciales(
        widget.tienda.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Ventas - ${widget.tienda.nombre}'),
      actions: [_buildCartButton(context)],
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return Consumer<CarritoManager>(
      builder: (context, carritoManager, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarritoScreen(
                      tienda: widget.tienda,
                      empresaId: widget.empresaId,
                    ),
                  ),
                );
              },
            ),
            if (carritoManager.totalItems > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${carritoManager.totalItems}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<VentaProductoManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (manager.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${manager.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    manager.cargarDatosIniciales(widget.tienda.id);
                  },
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildProductSelector(context, manager),
            if (manager.productoSeleccionado != null)
              _buildStockTiendaList(context, manager),
          ],
        );
      },
    );
  }

  Widget _buildProductSelector(
    BuildContext context,
    VentaProductoManager manager,
  ) {
    // Obtener productos únicos por nombre
    final productosUnicos = <String>{};
    final productosFiltrados = <StockTienda>[];

    for (var producto in manager.productosConStock) {
      if (!productosUnicos.contains(producto.nombre)) {
        productosUnicos.add(producto.nombre);
        productosFiltrados.add(producto);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<StockTienda>(
        decoration: InputDecoration(
          labelText: 'Seleccionar producto',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: productosFiltrados.map((producto) {
          return DropdownMenuItem<StockTienda>(
            value: producto,
            child: Text(producto.nombre),
          );
        }).toList(),
        onChanged: (producto) {
          if (producto != null) {
            manager.seleccionarProducto(producto);
          }
        },
      ),
    );
  }

  Widget _buildStockTiendaList(
    BuildContext context,
    VentaProductoManager manager,
  ) {
    // Filtrar todos los stocks del producto seleccionado
    final stockDelProducto = manager.productosConStock
        //.where((s) => s.nombre == manager.productoSeleccionado?.nombre)
        .toList();

    if (stockDelProducto.isEmpty) {
      return Center(child: Text('No hay stock disponible para este producto'));
    }

    // Agrupar stock por color
    final Map<String, StockTienda> stockAgrupado = {};
    for (var stock in stockDelProducto) {
      final key = stock.colorNombre;
      if (stockAgrupado.containsKey(key)) {
        final existente = stockAgrupado[key]!;
        stockAgrupado[key ?? 'Sin Color'] = existente.copyWith(
          cantidad: existente.cantidad + stock.cantidad,
          cantidadVendida: existente.cantidadVendida + stock.cantidadVendida,
          fechaIngresoStock:
              existente.fechaIngresoStock.isAfter(stock.fechaIngresoStock)
              ? existente.fechaIngresoStock
              : stock.fechaIngresoStock,
        );
      } else {
        stockAgrupado[key ?? "Sin Color"] = stock;
      }
    }

    final listaAgrupada = stockAgrupado.values.toList();

    return Expanded(
      child: ListView.builder(
        itemCount: listaAgrupada.length,
        itemBuilder: (context, index) {
          final stock = listaAgrupada[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _parseColor(stock.colorCodigo),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              title: Text(stock.nombre),
              subtitle: Text('Color: ${stock.colorNombre}'),
              trailing: Text(
                'Disponible1: ${stock.cantidadDisponible} ${stock.unidadMedida}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => _mostrarModalVenta(context, stock),
            ),
          );
        },
      ),
    );
  }

  void _mostrarModalVenta(BuildContext context, StockTienda stock) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Venta de ${stock.nombre}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              DefaultTabController(
                length: 2,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: stock.unidadMedidaSecundaria), // METRO
                          Tab(text: stock.unidadMedida), // ROLLO
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Contenido para venta por METRO
                            _buildVentaPorMetro(context, stock),
                            // Contenido para venta por ROLLO
                            _buildVentaPorRollo(context, stock),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVentaPorMetro(BuildContext context, StockTienda stock) {
    return Container(); //no desarrolar aun primero se necesita el por rollo
  }

  Future<List<StockTienda>> _cargarStocksActualizados(
    String nombreProducto,
    String colorNombre,
    String idTienda,
  ) async {
    final manager = context.read<VentaProductoManager>();

    // 1. Cargar los datos iniciales primero
    await manager.cargarDatosIniciales(idTienda);

    // 2. Filtrar por producto y color
    return manager.getStocksTiendaPorProductoColor(
      nombreProducto,
      colorNombre,
      idTienda,
    );
  }

  Widget _buildVentaPorRollo(BuildContext context, StockTienda stock) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentaProductoManager>().cargarDatosIniciales(
        widget.tienda.id,
      );
    });
    return Consumer<VentaProductoManager>(
      builder: (context, manager, child) {
        // Antes de construir la UI, cargamos los datos
        return FutureBuilder<List<StockTienda>>(
          future: manager.getStocksTiendaPorProductoColor(
            stock.nombre,
            stock.colorNombre ?? '',
            widget.tienda.id,
          ),
          builder: (context, snapshot) {
            // 1. Mostrar loading mientras se cargan los datos
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // 2. Mostrar error si ocurre alguno
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // 3. Cuando los datos ya están cargados
            final stocksTienda = snapshot.data ?? [];

            // Filtrar stocks con cantidad disponible
            final stocksDisponibles = stocksTienda
                .where((s) => s.cantidadDisponible > 0)
                .toList();

            if (stocksDisponibles.isEmpty) {
              return Center(
                child: Text(
                  'No hay ${stock.unidadMedida.toLowerCase()}s disponibles de ${stock.nombre} color ${stock.colorNombre}',
                ),
              );
            }

            // 4. Construir la lista de stocks
            return ListView.builder(
              itemCount: stocksDisponibles.length,
              itemBuilder: (context, index) {
                final stockTienda = stocksDisponibles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseColor(stockTienda.colorCodigo),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    title: Text(stockTienda.nombre),
                    subtitle: Text('Color: ${stockTienda.colorNombre}'),
                    trailing: Text(
                      'Disponible: ${stockTienda.cantidadDisponible} ${stockTienda.unidadMedida}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _mostrarDialogoVentaPorRollo(
                      context,
                      manager,
                      stockTienda,
                      stock,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoVentaPorRollo(
    BuildContext context,
    VentaProductoManager manager,
    StockTienda stockTienda,
    StockTienda stock,
  ) {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vender por ${stock.unidadMedida}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${stock.nombre}'),
              Text('Color: ${stock.colorNombre}'),
              Text(
                'Disponible6: ${stockTienda.cantidadDisponible} ${stock.unidadMedida}',
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (${stock.unidadMedida})',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una cantidad';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  if (cantidad > stockTienda.cantidadDisponible) {
                    return 'Stock insuficiente. Disponible: ${stockTienda.cantidadDisponible}';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final cantidad = int.parse(cantidadController.text);

                // Vender stock de tienda
                final resultado = await manager.venderStockTienda(
                  stockTienda.id,
                  cantidad,
                  widget.tienda.id,
                );

                if (resultado) {
                  // Crear item del carrito
                  final item = CarritoItem(
                    id: '${stockTienda.id}_rollo',
                    idProducto: stock.id,
                    nombreProducto: stock.nombre,
                    idColor: stock.idColor,
                    nombreColor: stock.colorNombre,
                    codigoColor: stock.colorCodigo,
                    precio: stock.precioVentaMenor,
                    cantidad: cantidad,
                    tipoVenta: 'UNIDAD_COMPLETA',
                  );

                  // Agregar al carrito
                  carritoManager.agregarUnidadCompleta(item, stockTienda.id);

                  // Cerrar modal
                  Navigator.pop(context);

                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto agregado al carrito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // Mostrar mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${manager.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Vender'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null) return Colors.grey;
    try {
      final color = hexColor.replaceAll('#', '');
      if (color.length == 6) {
        return Color(int.parse('FF$color', radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
