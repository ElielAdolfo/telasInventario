// lib/features/venta/ui/carrito_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/carrito_manager.dart';
import 'package:inventario/features/empresa/logic/venta_manager.dart';
import 'package:inventario/features/empresa/models/carrito_item_model.dart';
import 'package:inventario/features/empresa/models/tienda_model.dart';
import 'package:inventario/features/empresa/models/venta_item_model.dart';
import 'package:provider/provider.dart';
import '../models/venta_model.dart';

class CarritoScreen extends StatefulWidget {
  final Tienda tienda;
  final String empresaId;

  const CarritoScreen({
    super.key,
    required this.tienda,
    required this.empresaId,
  });

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final String? _userId;
  bool _mostrarTodasLasVentas = false;

  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;
    _tabController = TabController(length: 2, vsync: this);

    // Cargar carrito y ventas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarCarrito();
      _cargarVentas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para cargar el carrito
  Future<void> _cargarCarrito() async {
    final carritoManager = Provider.of<CarritoManager>(context, listen: false);
    await carritoManager.cargarCarrito(_userId ?? '');
  }

  // Método para cargar las ventas según el estado del switch
  void _cargarVentas() {
    if (_mostrarTodasLasVentas) {
      // Cargar todas las ventas de la tienda
      context.read<VentaManager>().loadVentasByTienda(widget.tienda.id);
    } else {
      // Cargar solo las ventas del usuario actual del día
      context.read<VentaManager>().loadVentasByTiendaAndUserAndDate(
        widget.tienda.id,
        _userId ?? '',
        DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tienda.nombre),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Carrito'),
            Tab(text: 'Ventas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCarritoTab(), _buildVentasTab()],
      ),
    );
  }

  Widget _buildCarritoTab() {
    return Consumer<CarritoManager>(
      builder: (context, carritoManager, child) {
        // Imprimir los items del carrito para debug
        if (carritoManager.items.isNotEmpty) {
          print("Items del carrito (${carritoManager.items.length}):");
          for (var item in carritoManager.items) {
            print("Producto: ${item.toString()}");
          }
        } else {
          print("El carrito está vacío");
        }

        if (carritoManager.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (carritoManager.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${carritoManager.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _cargarCarrito(),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (carritoManager.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: carritoManager.items.length,
                itemBuilder: (context, index) {
                  final item = carritoManager.items[index];
                  return _buildCarritoItem(context, carritoManager, item);
                },
              ),
            ),
            _buildTotalSection(context, carritoManager),
          ],
        );
      },
    );
  }

  Widget _buildVentasTab() {
    return Consumer<VentaManager>(
      builder: (context, ventaManager, child) {
        if (ventaManager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ventaManager.error != null) {
          return Center(child: Text('Error: ${ventaManager.error}'));
        }
        if (ventaManager.ventas.isEmpty) {
          return const Center(child: Text('No hay ventas registradas'));
        }

        return Column(
          children: [
            // Switch para filtrar ventas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _mostrarTodasLasVentas
                          ? 'Mostrando todas las ventas'
                          : 'Mostrando tus ventas de hoy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: _mostrarTodasLasVentas,
                    onChanged: (value) {
                      setState(() {
                        _mostrarTodasLasVentas = value;
                        _cargarVentas(); // Recargar datos cuando cambia el switch
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            // Lista de ventas
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _cargarVentas();
                },
                child: ListView.builder(
                  itemCount: ventaManager.ventas.length,
                  itemBuilder: (context, index) {
                    final venta = ventaManager.ventas[index];
                    return _buildVentaCard(venta);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarritoItem(
    BuildContext context,
    CarritoManager carritoManager,
    CarritoItem item,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Color
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(item.codigoColor),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // Detalles del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombreProducto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item.nombreColor ?? 'Sin Nombre Color'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Precio: \$${item.precio.toStringAsFixed(2)}'),
                      const SizedBox(width: 16),
                      Text('Cantidad: ${item.cantidad}'),
                    ],
                  ),
                ],
              ),
            ),
            // Subtotal y botones
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (item.cantidad > 1) {
                          carritoManager.actualizarCantidad(
                            item.id,
                            item.cantidad - 1,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        carritoManager.actualizarCantidad(
                          item.id,
                          item.cantidad + 1,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        carritoManager.removerItem(item.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentaCard(Venta venta) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text('Venta #${venta.id.substring(0, 6)}'),
        subtitle: Text(
          '${venta.fechaVenta.day}/${venta.fechaVenta.month}/${venta.fechaVenta.year} '
          '${venta.fechaVenta.hour}:${venta.fechaVenta.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Text(
          '\$${venta.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () => _verDetalleVenta(venta),
      ),
    );
  }

  Widget _buildTotalSection(
    BuildContext context,
    CarritoManager carritoManager,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${carritoManager.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _confirmarVenta(context, carritoManager),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Vender'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarVenta(BuildContext context, CarritoManager carritoManager) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Text(
          '¿Está seguro de realizar esta venta por un total de \$${carritoManager.total.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar el diálogo de confirmación
              _realizarVenta(context, carritoManager);
            },
            child: const Text('Vender'),
          ),
        ],
      ),
    );
  }

  void _realizarVenta(BuildContext context, CarritoManager carritoManager) {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Obtener el usuario actual
    final usuario = _userId ?? 'usuario_desconocido';

    // Crear la venta con todos los detalles necesarios
    final venta = Venta(
      id: '', // El ID será generado por Firebase
      idTienda: widget.tienda.id,
      idEmpresa: widget.empresaId,
      fechaVenta: DateTime.now(),
      total: carritoManager.total,
      realizadoPor: usuario,
      // Campos de auditoría
      createdAt: DateTime.now(),
      createdBy: usuario,
      updatedAt: DateTime.now(),
      updatedBy: usuario,
      items: carritoManager.items
          .map(
            (item) => VentaItem(
              idProducto: item.idProducto,
              nombreProducto: item.nombreProducto,
              idColor: item.idColor,
              nombreColor: item.nombreColor,
              codigoColor: item.codigoColor,
              precio: item.precio,
              cantidad: item.cantidad,
              subtotal: item.subtotal,
              tipoVenta: item.tipoVenta,
              idStockTienda: item.idStockTienda,
              idStockUnidadAbierta: item.idStockUnidadAbierta,
              idStockLoteTienda: item.idStockLoteTienda,
              codigoUnico: item.codigoUnico,
              // Campos de auditoría
              createdAt: DateTime.now(),
              createdBy: usuario,
              updatedAt: DateTime.now(),
              updatedBy: usuario,
            ),
          )
          .toList(),
      deleted: false,
    );

    // Registrar la venta
    context
        .read<VentaManager>()
        .registrarVenta(venta)
        .then((success) async {
          // Cerrar indicador de carga usando una forma segura
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          if (success) {
            // Vaciar carrito
            await carritoManager.vaciarCarrito();

            // Cambiar a la pestaña de ventas
            _tabController.animateTo(1);

            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venta realizada con éxito'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al realizar la venta: ${context.read<VentaManager>().error}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .catchError((error) {
          // Cerrar indicador de carga usando una forma segura
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _verDetalleVenta(Venta venta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle de Venta #${venta.id.substring(0, 6)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Fecha: ${_formatDate(venta.fechaVenta)}'),
              Text('Total: \$${venta.total.toStringAsFixed(2)}'),
              Text('Realizado por: ${venta.realizadoPor}'),
              // Mostrar información de auditoría
              if (venta.createdBy != null)
                Text('Creado por: ${venta.createdBy}'),
              if (venta.updatedBy != null)
                Text('Actualizado por: ${venta.updatedBy}'),
              const SizedBox(height: 16),
              const Text(
                'Productos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...venta.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _parseColor(item.codigoColor),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.nombreProducto} - ${item.nombreColor}',
                        ),
                      ),
                      Text(
                        '${item.cantidad} x \$${item.precio.toStringAsFixed(2)}',
                      ),
                      const SizedBox(width: 8),
                      Text('Subtotal: \$${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
