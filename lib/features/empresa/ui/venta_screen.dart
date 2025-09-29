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
        .where((s) => s.nombre == manager.productoSeleccionado?.nombre)
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
    final TabController tabController = TabController(
      length: 2,
      vsync: Scaffold.of(context),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                  initialIndex: 0,
                  child: Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          controller: tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: stock.unidadMedidaSecundaria), // METRO
                            Tab(text: stock.unidadMedida), // ROLLO
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              _buildVentaPorMetro(context, stock),
                              _buildVentaPorRollo(
                                context,
                                stock,
                                tabController,
                                1,
                              ), // Pasamos tabController y el índice
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
        );
      },
    );
  }

  Widget _buildVentaPorMetro(BuildContext context, StockTienda stock) {
    return Container(); //no desarrolar aun primero se necesita el por rollo
  }

  Widget _buildVentaPorRollo(
    BuildContext context,
    StockTienda stock,
    TabController tabController,
    int tabIndex,
  ) {
    final manager = context.read<VentaProductoManager>();
    Future<List<StockTienda>>? futureStocks;

    void cargar() {
      futureStocks = _cargarStocks(manager, stock);
    }

    tabController.addListener(() {
      if (tabController.index == tabIndex) {
        cargar();
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        if (futureStocks == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cargar();
            setState(() {});
          });
        }

        if (futureStocks == null) {
          return Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<List<StockTienda>>(
          future: futureStocks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final stocksTienda = snapshot.data ?? [];
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

            return ListView.builder(
              itemCount: stocksDisponibles.length,
              itemBuilder: (context, index) {
                final stockTienda = stocksDisponibles[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  elevation: 2,
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
                    title: Text(
                      '${stockTienda.nombre} - ${stockTienda.colorNombre}',
                    ),
                    subtitle: Text(
                      'Disponible: ${stockTienda.cantidadDisponible} ${stock.unidadMedida}\n'
                      'Ingreso: ${stockTienda.fechaIngresoStock.toLocal().toString().split(" ")[0]}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.green),
                          tooltip: 'Vender',
                          onPressed: () => _mostrarDialogoVentaPorRollo(
                            context,
                            manager,
                            stockTienda,
                            stock,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.lock_open, color: Colors.blue),
                          tooltip: 'Abrir Unidad',
                          onPressed: () => _abrirUnidad(
                            context,
                            stockTienda,
                            manager,
                            stock,
                          ),
                        ),
                      ],
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

  void _abrirUnidad(
    BuildContext context,
    StockTienda stockTienda,
    VentaProductoManager manager,
    StockTienda stock,
  ) {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    bool desbloqueado = false;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Abrir unidad de ${stock.nombre}'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nombre: ${stock.nombre}'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cantidadController,
                          enabled: desbloqueado,
                          decoration: InputDecoration(
                            labelText: 'Cantidad (${stock.unidadMedida})',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Ingrese una cantidad';
                            final cantidad = int.tryParse(value);
                            if (cantidad == null || cantidad <= 0)
                              return 'Cantidad inválida';
                            if (cantidad > stockTienda.cantidadDisponible) {
                              return 'Stock insuficiente. Disponible: ${stockTienda.cantidadDisponible}';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(desbloqueado ? Icons.lock_open : Icons.lock),
                        onPressed: () {
                          setStateDialog(() {
                            desbloqueado = true; // desbloquea el input
                          });
                        },
                      ),
                    ],
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

                    // Aquí vendes la cantidad abierta
                    final resultado = await manager.venderStockTienda(
                      stockTienda.id,
                      cantidad,
                      stockTienda.idTienda,
                    );

                    if (resultado) {
                      final item = CarritoItem(
                        id: '${stockTienda.id}_unidad',
                        idProducto: stock.id,
                        nombreProducto: stock.nombre,
                        idColor: stock.idColor,
                        nombreColor: stock.colorNombre,
                        codigoColor: stock.colorCodigo,
                        precio: stock.precioVentaMenor,
                        cantidad: cantidad,
                        tipoVenta: 'UNIDAD_ABIERTA',
                      );

                      //carritoManager.agregarUnidadAbierta(item, stockTienda.id);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unidad agregada al carrito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${manager.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('Agregar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<StockTienda>> _cargarStocks(
    VentaProductoManager manager,
    StockTienda stock,
  ) async {
    await manager.cargarDatosIniciales(widget.tienda.id);
    return manager.getStocksTiendaPorProductoColor(
      stock.nombre,
      stock.colorNombre ?? '',
      widget.tienda.id,
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
    final TextEditingController precioController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Calcular precio inicial (cantidadPrioritaria * precioVentaMenor)
    final precioInicial = stock.cantidadPrioritaria * stock.precioVentaMenor;
    precioController.text = precioInicial.toStringAsFixed(2);

    // Variable para el subtotal
    double subtotal = precioInicial;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Calcular subtotal cuando cambian los valores
          void calcularSubtotal() {
            final cantidad = int.tryParse(cantidadController.text) ?? 0;
            final precio = double.tryParse(precioController.text) ?? 0;
            setState(() {
              subtotal = cantidad * precio;
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseColor(stock.colorCodigo),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agregar al carrito - ${stock.unidadMedida}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del producto
                    _buildInfoCard(
                      title: 'Información del Producto',
                      children: [
                        _buildInfoRow('Producto:', stock.nombre),
                        _buildInfoRow(
                          'Color:',
                          stock.colorNombre ?? 'Sin color',
                        ),
                        _buildInfoRow(
                          'Disponible:',
                          '${stockTienda.cantidadDisponible} ${stock.unidadMedida}',
                        ),
                        _buildInfoRow(
                          'Fecha de ingreso:',
                          stock.fechaIngresoStock.toString().substring(0, 10),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Campos de entrada
                    _buildInputCard(
                      title: 'Detalles de Venta',
                      children: [
                        TextFormField(
                          controller: cantidadController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad (${stock.unidadMedida})',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => calcularSubtotal(),
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
                        SizedBox(height: 12),
                        TextFormField(
                          controller: precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio por ${stock.unidadMedida}',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            suffixText: 'Bs',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) => calcularSubtotal(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un precio';
                            }
                            final precio = double.tryParse(value);
                            if (precio == null || precio <= 0) {
                              return 'Ingrese un precio válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Subtotal:',
                          '\$${subtotal.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          'Cantidad restante:',
                          '${stockTienda.cantidadDisponible - (int.tryParse(cantidadController.text) ?? 0)} ${stock.unidadMedida}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final cantidad = int.parse(cantidadController.text);
                    final precio = double.parse(precioController.text);

                    // Crear item del carrito con todos los campos necesarios
                    final item = CarritoItem(
                      id: '${stockTienda.id}_rollo_${DateTime.now().millisecondsSinceEpoch}',
                      idProducto: stock.id,
                      nombreProducto: stock.nombre,
                      idColor: stock.idColor,
                      nombreColor: stock.colorNombre,
                      codigoColor: stock.colorCodigo,
                      precio: precio,
                      cantidad: cantidad,
                      tipoVenta: 'UNIDAD_COMPLETA',
                      idStockTienda:
                          stockTienda.id, // Guardamos referencia al stock
                    );

                    // Agregar al carrito (sin vender todavía)
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
                  }
                },
                child: Text('Agregar al carrito'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget auxiliar para crear tarjetas de información
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para crear tarjetas de entrada
  Widget _buildInputCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para filas de información
  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
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
