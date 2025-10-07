// lib/features/empresa/ui/venta_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
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

  const VentaScreen({super.key, required this.empresaId, required this.tienda});

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
    super.key,
    required this.empresaId,
    required this.tienda,
  });

  @override
  __VentaScreenContentState createState() => __VentaScreenContentState();
}

class __VentaScreenContentState extends State<_VentaScreenContent> {
  late final String? _userId;
  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;
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
                'Disponible: ${stock.cantidadDisponible} ${stock.unidadMedida}',
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
    final manager = context.read<VentaProductoManager>();
    final futureLotes = manager.getLotesPorProductoColor(
      stock.nombre,
      stock.colorNombre ?? '',
      widget.tienda.id,
    );

    final TabController tabController = TabController(
      length: 2,
      vsync: Scaffold.of(context),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
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
                          child: FutureBuilder<List<StockLoteTienda>>(
                            future: futureLotes,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              // ✅ Pasamos los datos ya listos
                              return TabBarView(
                                controller: tabController,
                                children: [
                                  _buildVentaPorMetro(
                                    context,
                                    stock,
                                    tabController,
                                    0,
                                  ),
                                  _buildVentaPorRollo(
                                    context,
                                    stock,
                                    tabController,
                                    1,
                                  ), // Pasamos tabController y el índice
                                ],
                              );
                            },
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

  Widget _buildVentaPorMetro(
    BuildContext context,
    StockTienda stock,
    TabController tabController,
    int tabIndex,
  ) {
    final manager = context.read<VentaProductoManager>();
    Future<List<StockLoteTienda>>? futureLotes;

    void cargar() {
      futureLotes = manager.getLotesPorProductoColor(
        stock.nombre,
        stock.colorNombre ?? '',
        widget.tienda.id,
      );
      print(
        "Cargando datos de lotes para: ${stock.nombre} - ${stock.colorNombre}",
      );
    }

    if (tabController.index == tabIndex && futureLotes == null) {
      cargar();
    }

    tabController.addListener(() {
      if (tabController.index == tabIndex) {
        cargar();
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        if (futureLotes == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cargar();
            setState(() {});
          });
        }

        return FutureBuilder<List<StockLoteTienda>>(
          future: futureLotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Error al cargar lotes: ${snapshot.error}");
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final lotes = snapshot.data ?? [];
            print(
              "Lotes obtenidos: ${lotes.length}",
            ); // Filtrar lotes que estén abiertos y tengan stock disponible
            final lotesDisponibles = lotes
                .where((lote) => lote.cantidadDisponible > 0)
                .toList();

            print("Lotes disponibles: ${lotesDisponibles.length}");

            if (lotesDisponibles.isEmpty) {
              return Center(
                child: Text(
                  'No hay ${stock.unidadMedidaSecundaria?.toLowerCase() ?? 'unidad'}s abiertos de ${stock.nombre} color ${stock.colorNombre}',
                ),
              );
            }

            return ListView.builder(
              itemCount: lotesDisponibles.length,
              itemBuilder: (context, index) {
                final lote = lotesDisponibles[index];

                print(
                  "Mostrando lote: ${lote.id}, cantidad: ${lote.cantidadDisponible}",
                );
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
                        color: _parseColor(stock.colorCodigo),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    title: Text('${stock.nombre} - ${stock.colorNombre}'),
                    subtitle: Text(
                      'Disponible: ${lote.cantidadDisponible} ${stock.unidadMedidaSecundaria}\n'
                      'Apertura: ${lote.fechaApertura.toLocal().toString().split(" ")[0]}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.green,
                      ),
                      tooltip: 'Vender',
                      onPressed: () => _confirmarVentaPorMetro(
                        context,
                        manager,
                        lote,
                        stock,
                      ),
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

  void _confirmarVentaPorMetro(
    BuildContext context,
    VentaProductoManager manager,
    StockLoteTienda lote,
    StockTienda stock,
  ) {
    // Validar stock disponible
    if (lote.cantidadDisponible < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay stock disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final carritoManager = Provider.of<CarritoManager>(context, listen: false);

    // Mostrar diálogo de confirmación simple
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Producto: ${stock.nombre}'),
            Text('Color: ${stock.colorNombre}'),
            Text('Código: ${stock.colorCodigo ?? "N/A"}'),
            Text('Subtotal: \$${stock.precioVentaMenor.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Crear item del carrito con valores fijos
              final item = CarritoItem(
                id: '${lote.id}_${DateTime.now().millisecondsSinceEpoch}',
                idProducto: stock.id,
                nombreProducto: stock.nombre,
                idColor: stock.idColor,
                nombreColor: stock.colorNombre,
                codigoColor: stock.colorCodigo,
                precio: stock.precioVentaMenor,
                codigoUnico: stock.codigoUnico,
                cantidad: 1,
                tipoVenta: 'UNIDAD_ABIERTA',
                idStockLoteTienda: lote.id,
                idUsuario: _userId ?? 'usuario_desconocido',
              );

              // Agregar al carrito
              carritoManager.agregarUnidadAbierta(item, lote.id);

              // Cerrar modal
              Navigator.pop(context);

              // Mostrar mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Producto agregado al carrito'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildVentaPorRollo(
    BuildContext context,
    StockTienda stock,
    TabController tabController,
    int tabIndex,
  ) {
    final manager = context.read<VentaProductoManager>();
    Future<List<StockTienda>>? futureStocks;
    final TextEditingController codigoBusquedaController =
        TextEditingController();

    void cargarRollos() {
      futureStocks = _cargarStocks(manager, stock);
    }

    tabController.addListener(() {
      if (tabController.index == tabIndex) {
        cargarRollos();
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        if (futureStocks == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cargarRollos();
            setState(() {});
          });
        }

        // Función para recargar los datos
        void recargar() {
          cargarRollos();
          setState(() {});
        }

        return Column(
          children: [
            // Campo de búsqueda por código
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codigoBusquedaController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por código',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('Buscar'),
                  ),
                ],
              ),
            ),

            // Lista de rollos
            Expanded(
              child: FutureBuilder<List<StockTienda>>(
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

                  // Filtrar por código si se ha ingresado algo en el campo de búsqueda
                  String codigoBusqueda = codigoBusquedaController.text.trim();
                  List<StockTienda> stocksFiltrados = stocksDisponibles;

                  if (codigoBusqueda.isNotEmpty) {
                    stocksFiltrados = stocksDisponibles
                        .where(
                          (s) =>
                              s.codigoUnico?.contains(codigoBusqueda) ?? false,
                        )
                        .toList();
                  }

                  if (stocksFiltrados.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay ${stock.unidadMedida.toLowerCase()}s disponibles de ${stock.nombre} color ${stock.colorNombre}',
                      ),
                    );
                  }

                  return Consumer<CarritoManager>(
                    builder: (context, carritoManager, child) {
                      return ListView.builder(
                        itemCount: stocksFiltrados.length,
                        itemBuilder: (context, index) {
                          final stockTienda = stocksFiltrados[index];

                          // Calcular subtotal: metraje * precioPaquete
                          final subtotal =
                              stockTienda.cantidad *
                              (stockTienda.precioPaquete ?? 0);

                          // Verificar si el rollo ya está en el carrito
                          final bool enCarrito = carritoManager.items.any(
                            (item) =>
                                item.idStockTienda == stockTienda.id &&
                                item.tipoVenta == 'UNIDAD_COMPLETA',
                          );

                          return Card(
                            color: enCarrito
                                ? Colors.red[50]
                                : null, // Color rojo suave si está en el carrito
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Código: ${stockTienda.codigoUnico ?? "N/A"}',
                                  ),
                                  Text('Metros: ${stockTienda.cantidad}'),
                                  Text(
                                    'Precio por paquete: \$${(stockTienda.precioPaquete ?? 0).toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botón de abrir rollo
                                  if (!enCarrito)
                                    IconButton(
                                      icon: Icon(
                                        Icons.open_in_new,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Abrir rollo',
                                      onPressed: () => _confirmarAbrirRollo(
                                        context,
                                        manager,
                                        stockTienda,
                                        stock,
                                        recargar,
                                      ),
                                    ),
                                  // Botón de vender (solo si no está en el carrito)
                                  if (!enCarrito)
                                    IconButton(
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Vender',
                                      onPressed: () => _confirmarVentaPorRollo(
                                        context,
                                        manager,
                                        stockTienda,
                                        stock,
                                      ),
                                    ),
                                  // Si está en el carrito, mostrar un icono de check
                                  if (enCarrito)
                                    Icon(Icons.check_circle, color: Colors.red),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmarVentaPorRollo(
    BuildContext context,
    VentaProductoManager manager,
    StockTienda stockTienda,
    StockTienda stock,
  ) {
    // Validar stock disponible
    if (stockTienda.cantidadDisponible < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay stock disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final carritoManager = Provider.of<CarritoManager>(context, listen: false);

    // Mostrar diálogo de confirmación simple
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Producto: ${stock.nombre}'),
            Text('Color: ${stock.colorNombre}'),
            Text('Cantidad: ${stockTienda.cantidad ?? "N/A"}'),
            Text('Código: ${stockTienda.codigoUnico ?? "N/A"}'),
            Text(
              'Subtotal: \$${((stockTienda.precioPaquete! * stockTienda.cantidad!) ?? 0).toStringAsFixed(2)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Crear item del carrito con valores fijos
              print(stock.toString());
              final item = CarritoItem(
                id: '${stockTienda.id}_rollo_${DateTime.now().millisecondsSinceEpoch}',
                idProducto: stock.id,
                nombreProducto: stock.nombre,
                idColor: stock.idColor,
                nombreColor: stock.colorNombre,
                codigoColor: stock.colorCodigo,
                codigoUnico: stock.codigoUnico,
                precio: stockTienda.precioPaquete ?? 0,
                cantidad: stockTienda.cantidad,
                tipoVenta: 'UNIDAD_COMPLETA',
                idStockTienda: stockTienda.id,
                idUsuario: _userId ?? 'usuario_desconocido',
              );
              print('Calor de Carrito:\n' + item.toString());
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
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmarAbrirRollo(
    BuildContext context,
    VentaProductoManager manager,
    StockTienda stockTienda,
    StockTienda stock,
    VoidCallback recargar,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar apertura'),
        content: Text(
          '¿Está seguro de abrir el rollo ${stockTienda.codigoUnico ?? ""} de ${stock.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final resultado = await manager.abrirUnidad(
                stockTienda.id,
                1, // cantidadUnidades, por defecto 1
                _userId!, // usuario actual
                widget.tienda.id,
                stockTienda.codigoUnico,
                stockTienda.idTipoProducto!,
                stockTienda.idEmpresa,
                stockTienda.idColor,
                stockTienda.cantidad, //cantidadMetraje
              );

              Navigator.pop(context); // cerrar el diálogo de confirmación

              if (resultado) {
                // Mostrar modal informativo de éxito
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 30),
                        SizedBox(width: 10),
                        Text('Éxito'),
                      ],
                    ),
                    content: const Text('Unidad abierta correctamente.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // cerrar modal de éxito

                          // 🔄 Refrescar lista después de cerrar el modal
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            recargar();
                          });
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                // Modal de error
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.red, size: 30),
                        SizedBox(width: 10),
                        Text('Error'),
                      ],
                    ),
                    content: Text(manager.error ?? 'Error desconocido.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Abrir'),
          ),
        ],
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
