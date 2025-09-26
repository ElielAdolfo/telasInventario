// lib/features/empresa/ui/venta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/venta_producto_manager.dart';
import '../logic/carrito_manager.dart';
import '../models/stock_tienda_model.dart';
import '../models/stock_lote_tienda_model.dart';
import '../models/stock_unidad_abierta_model.dart';
import '../models/color_model.dart';
import '../models/carrito_item_model.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(appBar: _buildAppBar(context), body: _buildBody(context)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Ventas - ${widget.tienda.nombre}'),
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Por Unidad'),
          Tab(text: 'Por Metro'),
        ],
      ),
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
    return TabBarView(
      children: [_buildVentaPorUnidad(context), _buildVentaPorMetro(context)],
    );
  }

  Widget _buildVentaPorUnidad(BuildContext context) {
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

        if (manager.productosConStock.isEmpty) {
          return Center(child: Text('No hay productos disponibles'));
        }

        return Column(
          children: [
            _buildProductSelector(context, manager),
            if (manager.productoSeleccionado != null)
              _buildLotesList(context, manager),
          ],
        );
      },
    );
  }

  Widget _buildVentaPorMetro(BuildContext context) {
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

        if (manager.unidadesAbiertasDisponibles.isEmpty) {
          return Center(child: Text('No tiene ninguna unidad abierta'));
        }

        return ListView.builder(
          itemCount: manager.unidadesAbiertasDisponibles.length,
          itemBuilder: (context, index) {
            final unidad = manager.unidadesAbiertasDisponibles[index];
            return _buildUnidadAbiertaItem(context, manager, unidad);
          },
        );
      },
    );
  }

  Widget _buildProductSelector(
    BuildContext context,
    VentaProductoManager manager,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<StockTienda>(
        decoration: InputDecoration(
          labelText: 'Seleccionar producto',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: manager.productosConStock.map((producto) {
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

  Widget _buildLotesList(BuildContext context, VentaProductoManager manager) {
    // Filtrar lotes que pertenezcan al producto seleccionado
    final lotesDelProducto = manager.lotesDisponibles.where((lote) {
      final stockTienda = manager.productosConStock.firstWhere(
        (s) => s.idsLotes.contains(lote.id),
        orElse: () => StockTienda.empty(),
      );
      return stockTienda.idTipoProducto ==
          manager.productoSeleccionado?.idTipoProducto;
    }).toList();

    if (lotesDelProducto.isEmpty) {
      return Center(child: Text('No hay lotes disponibles para este producto'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: lotesDelProducto.length,
        itemBuilder: (context, index) {
          final lote = lotesDelProducto[index];
          return _buildLoteItem(context, manager, lote);
        },
      ),
    );
  }

  Widget _buildLoteItem(
    BuildContext context,
    VentaProductoManager manager,
    StockLoteTienda lote,
  ) {
    final stockTienda = manager.productosConStock.firstWhere(
      (s) => s.idsLotes.contains(lote.id),
      orElse: () => StockTienda.empty(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          'Disponible: ${lote.cantidadDisponible} ${stockTienda.unidadMedida}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () =>
            _mostrarDialogoCantidad(context, manager, lote, stockTienda),
      ),
    );
  }

  Widget _buildUnidadAbiertaItem(
    BuildContext context,
    VentaProductoManager manager,
    StockUnidadAbierta unidad,
  ) {
    final lote = manager.lotesDisponibles.firstWhere(
      (l) => l.id == unidad.idStockLoteTienda,
      orElse: () => StockLoteTienda.empty(),
    );

    final stockTienda = manager.productosConStock.firstWhere(
      (s) => s.idsLotes.contains(lote.id),
      orElse: () => StockTienda.empty(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          'Disponible: ${unidad.cantidadDisponible} ${stockTienda.unidadMedidaSecundaria}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => _mostrarDialogoCantidadPorMetro(
          context,
          manager,
          unidad,
          stockTienda,
        ),
      ),
    );
  }

  void _mostrarDialogoCantidad(
    BuildContext context,
    VentaProductoManager manager,
    StockLoteTienda lote,
    StockTienda stockTienda,
  ) {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar al carrito'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${stockTienda.nombre}'),
              Text('Color: ${stockTienda.colorNombre}'),
              SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (${stockTienda.unidadMedida})',
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
                  if (cantidad > lote.cantidadDisponible) {
                    return 'Stock insuficiente. Disponible: ${lote.cantidadDisponible}';
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cantidad = int.parse(cantidadController.text);

                // Crear item del carrito
                final item = CarritoItem(
                  id: '${lote.id}_completa',
                  idProducto: stockTienda.id,
                  nombreProducto: stockTienda.nombre,
                  idColor: stockTienda.idColor,
                  nombreColor: stockTienda.colorNombre,
                  codigoColor: stockTienda.colorCodigo,
                  precio: stockTienda.precioVentaMenor,
                  cantidad: cantidad,
                  tipoVenta: 'UNIDAD_COMPLETA',
                  idStockLoteTienda: lote.id,
                );

                // Agregar al carrito
                carritoManager.agregarUnidadCompleta(item, lote.id);

                // Cerrar modal
                Navigator.pop(context);

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto agregado al carrito'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCantidadPorMetro(
    BuildContext context,
    VentaProductoManager manager,
    StockUnidadAbierta unidad,
    StockTienda stockTienda,
  ) {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar al carrito'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${stockTienda.nombre}'),
              Text('Color: ${stockTienda.colorNombre}'),
              SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (${stockTienda.unidadMedidaSecundaria})',
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
                  if (cantidad > unidad.cantidadDisponible) {
                    return 'Stock insuficiente. Disponible: ${unidad.cantidadDisponible}';
                  }
                  // Validar que la cantidad esté entre las cantidades posibles
                  if (!stockTienda.cantidadesPosibles.contains(cantidad)) {
                    return 'La cantidad debe ser una de las siguientes: ${stockTienda.cantidadesPosibles.join(", ")}';
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cantidad = int.parse(cantidadController.text);

                // Crear item del carrito
                final item = CarritoItem(
                  id: '${unidad.id}_metro',
                  idProducto: stockTienda.id,
                  nombreProducto: stockTienda.nombre,
                  idColor: stockTienda.idColor,
                  nombreColor: stockTienda.colorNombre,
                  codigoColor: stockTienda.colorCodigo,
                  precio: stockTienda.precioVentaMenor,
                  cantidad: cantidad,
                  tipoVenta: 'UNIDAD_ABIERTA',
                  idStockUnidadAbierta: unidad.id,
                );

                // Agregar al carrito
                carritoManager.agregarPorMetro(item, unidad.id);

                // Cerrar modal
                Navigator.pop(context);

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto agregado al carrito'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Agregar'),
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
