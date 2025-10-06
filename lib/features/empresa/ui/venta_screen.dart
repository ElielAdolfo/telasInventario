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
      print("entro a cargar datos");
    }

    // ✅ Se carga inmediatamente si el tab inicial es el mismo
    if (tabController.index == tabIndex && futureLotes == null) {
      cargar();
    }

    // ✅ Detecta cuando se cambia a este tab
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
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final lotes = snapshot.data ?? [];
            final lotesDisponibles = lotes
                .where((lote) => lote.cantidadDisponible > 0)
                .toList();

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
                      onPressed: () => _mostrarDialogoVentaPorMetro(
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

  void _mostrarDialogoVentaPorMetro(
    BuildContext context,
    VentaProductoManager manager,
    StockLoteTienda lote,
    StockTienda stock,
  ) {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    final TextEditingController precioController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Calcular precio inicial (precio por unidad secundaria)
    final precioInicial = stock.precioVentaMenor; // Precio por metro
    precioController.text = precioInicial.toStringAsFixed(2);

    // Variable para el subtotal
    double subtotal = precioInicial;

    // Variable para controlar si se usa precio por mayor
    bool usarPrecioPorMayor = false;

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

          // Cambiar entre precio normal y precio por mayor
          void togglePrecioPorMayor(bool valor) {
            setState(() {
              usarPrecioPorMayor = valor;
              if (valor) {
                // Usar precio por mayor
                precioController.text = stock.precioVentaMayor.toStringAsFixed(
                  2,
                );
              } else {
                // Usar precio normal
                precioController.text = stock.precioVentaMenor.toStringAsFixed(
                  2,
                );
              }
              calcularSubtotal();
            });
          }

          // Verificar si se debe activar automáticamente el precio por mayor
          void verificarActivacionPrecioPorMayor() {
            final cantidad = int.tryParse(cantidadController.text) ?? 0;
            if (cantidad >= 10 && !usarPrecioPorMayor) {
              // Activar automáticamente si la cantidad es 10 o más
              togglePrecioPorMayor(true);
            } else if (cantidad < 10 && usarPrecioPorMayor) {
              // Desactivar automáticamente si la cantidad es menor a 10
              togglePrecioPorMayor(false);
            }
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
                        'Vender por ${stock.unidadMedidaSecundaria}',
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
                          '${lote.cantidadDisponible} ${stock.unidadMedidaSecundaria}',
                        ),
                        _buildInfoRow(
                          'Fecha de apertura:',
                          lote.fechaApertura.toString().substring(0, 10),
                        ),
                        // Mostrar precios de referencia
                        _buildInfoRow(
                          'Precio normal:',
                          '\$${stock.precioVentaMenor.toStringAsFixed(2)}',
                          color: Colors.blue,
                        ),
                        _buildInfoRow(
                          'Precio por mayor (10+):',
                          '\$${stock.precioVentaMayor.toStringAsFixed(2)}',
                          color: Colors.green,
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
                            labelText:
                                'Cantidad (${stock.unidadMedidaSecundaria})',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2),
                            helperText:
                                'Al ingresar 10 o más unidades, se aplicará precio por mayor automáticamente',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            calcularSubtotal();
                            verificarActivacionPrecioPorMayor();
                          },
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
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: precioController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Precio por ${stock.unidadMedidaSecundaria}',
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
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 60,
                              child: InkWell(
                                onTap: () =>
                                    togglePrecioPorMayor(!usarPrecioPorMayor),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: usarPrecioPorMayor
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: usarPrecioPorMayor
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        usarPrecioPorMayor
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: usarPrecioPorMayor
                                            ? Colors.white
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      Text(
                                        'Mayor',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: usarPrecioPorMayor
                                              ? Colors.white
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          '${lote.cantidadDisponible - (int.tryParse(cantidadController.text) ?? 0)} ${stock.unidadMedidaSecundaria}',
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
                      id: '${lote.id}_${DateTime.now().millisecondsSinceEpoch}',
                      idProducto: stock.id,
                      nombreProducto: stock.nombre,
                      idColor: stock.idColor,
                      nombreColor: stock.colorNombre,
                      codigoColor: stock.colorCodigo,
                      precio: precio,
                      cantidad: cantidad,
                      tipoVenta: 'UNIDAD_ABIERTA',
                      idStockLoteTienda:
                          lote.id, // Guardamos referencia al lote
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Agregar al carrito'),
              ),
            ],
          );
        },
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
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una cantidad';
                            }
                            final cantidad = int.tryParse(value);
                            if (cantidad == null || cantidad <= 0) {
                              return 'Cantidad inválida';
                            }
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
                    final cantidad = double.parse(cantidadController.text);

                    // Abrir las unidades
                    final resultado = await manager.abrirUnidad(
                      stockTienda.id,
                      cantidad, // cantidadUnidades
                      _userId!, // Esto debería ser el usuario actual
                      widget.tienda.id,
                    );

                    if (resultado) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unidades abiertas correctamente'),
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

    // CORREGIDO: Usar precioPaquete en lugar de calcular con cantidadPrioritaria
    final precioInicial =
        stock.precioPaquete ??
        -1; //stock.cantidadPrioritaria * stock.precioVentaMenor;
    precioController.text = precioInicial.toStringAsFixed(2);

    // Variable para el subtotal
    double subtotal = precioInicial * stock.cantidad;

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
                        'Agregar al carrito -  ${stock.unidadMedida}',
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
                        // AGREGADO: Mostrar precioPaquete
                        _buildInfoRow(
                          'Precio por paquete:',
                          '\$${stock.precioPaquete?.toStringAsFixed(2) ?? "N/A"}',
                          isBold: true,
                          color: Colors.green,
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
                      idUsuario: _userId ?? 'usuario_desconocido',
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Agregar al carrito'),
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
