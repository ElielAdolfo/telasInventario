// lib/features/stock/ui/detalle_stock_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/color_con_cantidad_model.dart';
import 'package:inventario/features/empresa/models/item_stock_model.dart';
import 'package:inventario/features/empresa/models/stock_empresa_model.dart';
import 'package:inventario/features/empresa/models/tipo_producto_model.dart';
import 'package:inventario/features/empresa/services/bolsa_colores_service.dart';
import 'package:inventario/features/empresa/services/codigo_service.dart';
import 'package:inventario/features/empresa/services/stock_empresa_service.dart';

class DetalleStockScreen extends StatefulWidget {
  final String idEmpresa;
  final String empresaNombre;
  final TipoProducto tipoProducto;
  final List<ColorConCantidad> coloresSeleccionados;
  final String? userId;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? observaciones;
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete;

  const DetalleStockScreen({
    super.key,
    required this.idEmpresa,
    required this.empresaNombre,
    required this.tipoProducto,
    required this.coloresSeleccionados,
    this.userId,
    this.lote,
    this.fechaVencimiento,
    this.observaciones,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
  });

  @override
  State<DetalleStockScreen> createState() => _DetalleStockScreenState();
}

class _DetalleStockScreenState extends State<DetalleStockScreen> {
  // Lista para almacenar todos los items individuales generados
  List<ItemStock> _items = [];

  // Servicio para gestionar los códigos únicos
  final CodigoService _codigoService = CodigoService();

  // Servicio para gestionar el stock
  final StockEmpresaService _stockEmpresaService = StockEmpresaService();

  // Controladores para los campos editables
  final Map<String, TextEditingController> _metrajeControllers = {};

  // Último código utilizado
  String _ultimoCodigo = 'A-0000';

  @override
  void initState() {
    super.initState();
    _cargarUltimoCodigo().then((_) {
      // Una vez cargado el último código, generar los items
      _generarItems();
    });
  }

  @override
  void dispose() {
    // Liberar todos los controladores
    for (var controller in _metrajeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Cargar el último código utilizado desde la base de datos
  Future<void> _cargarUltimoCodigo() async {
    try {
      // Primero intentar obtener el último código de la tabla codigos_stock
      final ultimoCodigo = await _codigoService.obtenerUltimoCodigo();
      //asta aqui llego correctamente nos devolvio el ultimo codigo: A-0005
      print("nos devolvio el ultimo codigo: " + ultimoCodigo.toString());

      if (ultimoCodigo != null) {
        setState(() {
          _ultimoCodigo = ultimoCodigo;
        });
      } else {
        // Si no hay ningún código, usar el valor por defecto
        setState(() {
          _ultimoCodigo = 'A-0000';
        });
      }
    } catch (e) {
      print("Error al cargar último código: $e");
      // En caso de error, usar el valor por defecto
      setState(() {
        _ultimoCodigo = 'A-0000';
      });
    }
  }

  // Generar todos los items individuales a partir de los colores seleccionados
  void _generarItems() {
    List<ItemStock> itemsTemp = [];
    String codigoActual = _ultimoCodigo;
    codigoActual = _codigoService.generarSiguienteCodigo(codigoActual);

    for (var colorConCantidad in widget.coloresSeleccionados) {
      // Por cada unidad, crear un item individual
      for (int i = 0; i < colorConCantidad.unidades; i++) {
        final item = ItemStock(
          id: '${colorConCantidad.color.id}-${i}',
          codigo: codigoActual,
          color: colorConCantidad.color,
          metraje: colorConCantidad.cantidad,
          precioCompra: widget.precioCompra,
          precioVentaMenor: widget.precioVentaMenor,
          precioVentaMayor: widget.precioVentaMayor,
          precioPaquete: widget.precioPaquete,
          lote: widget.lote,
          fechaVencimiento: widget.fechaVencimiento,
          observaciones: widget.observaciones,
        );

        itemsTemp.add(item);

        // Crear controlador para el metraje
        _metrajeControllers[item.id] = TextEditingController(
          text: colorConCantidad.cantidad.toString(),
        );
        // Generar el siguiente código para el próximo item
        codigoActual = _codigoService.generarSiguienteCodigo(codigoActual);
      }
    }

    setState(() {
      _items = itemsTemp;
    });
  }

  // Obtener el siguiente código en la secuencia
  String _siguienteCodigo(String codigoActual) {
    // Formato esperado: A-0001, B-0001, etc.
    final partes = codigoActual.split('-');
    if (partes.length != 2) return 'A-0001';

    final letra = partes[0];
    final numero = int.tryParse(partes[1]) ?? 0;

    if (numero < 9999) {
      // Incrementar el número
      return '$letra-${(numero + 1).toString().padLeft(4, '0')}';
    } else {
      // Cambiar a la siguiente letra
      final siguienteLetra = String.fromCharCode(letra.codeUnitAt(0) + 1);
      return '$siguienteLetra-0001';
    }
  }

  // Actualizar el metraje de un item específico
  void _actualizarMetraje(String itemId, double nuevoMetraje) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(metraje: nuevoMetraje);
      }
    });
  }

  // Guardar el stock y enviar la solicitud
  Future<void> _guardarStock() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar indicador de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Procesando stock...'),
          ],
        ),
      ),
    );

    try {
      // Guardar el último código utilizado
      if (_items.isNotEmpty) {
        await _codigoService.actualizarUltimoCodigo(_items.last.codigo);
      }

      // Guardar cada item individualmente en la base de datos
      for (var item in _items) {
        final stock = StockEmpresa(
          id: '',
          idEmpresa: widget.idEmpresa,
          idTipoProducto: widget.tipoProducto.id,
          idColor: item.color.id,
          cantidad: item.metraje, // Usamos el metraje editado por el usuario
          cantidadReservado: 0,
          cantidadAprobado: 0,
          unidades: 1, // Cada item es una unidad individual
          precioCompra: item.precioCompra,
          precioVentaMenor: item.precioVentaMenor,
          precioVentaMayor: item.precioVentaMayor,
          precioPaquete: item.precioPaquete,
          fechaIngreso: DateTime.now(),
          lote: item.lote,
          fechaVencimiento: item.fechaVencimiento,
          observaciones: item.observaciones,
          deleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // Campos adicionales del TipoProducto
          categoria: widget.tipoProducto.categoria,
          nombre: widget.tipoProducto.nombre,
          unidadMedida: widget.tipoProducto.unidadMedida,
          unidadMedidaSecundaria: widget.tipoProducto.unidadMedidaSecundaria,
          permiteVentaParcial: widget.tipoProducto.permiteVentaParcial,
          requiereColor: widget.tipoProducto.requiereColor,
          cantidadesPosibles: widget.tipoProducto.cantidadesPosibles
              .cast<double>(),
          cantidadPrioritaria: widget.tipoProducto.cantidadPrioritaria,
          createdBy: widget.userId,
          updatedBy: widget.userId,
          deletedBy: null,
          deletedAt: null,
          // CAMPO NUEVO: Guardar el código único del rollo
          codigoUnico: item.codigo,
        );

        await _stockEmpresaService.createStockEmpresa(stock, widget.userId!);
      }

      // Cerrar diálogo de progreso
      Navigator.pop(context);
      Navigator.pop(context);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se agregaron ${_items.length} registros de stock correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de progreso
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el stock: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Stock - ${widget.empresaNombre}')),
      body: Column(
        children: [
          // Información del producto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tipoProducto.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total de items: ${_items.length}'),
                    if (widget.lote != null) ...[
                      const SizedBox(height: 4),
                      Text('Lote: ${widget.lote}'),
                    ],
                    if (widget.fechaVencimiento != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Vence: ${widget.fechaVencimiento!.day.toString().padLeft(2, '0')}/${widget.fechaVencimiento!.month.toString().padLeft(2, '0')}/${widget.fechaVencimiento!.year}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Encabezado de la tabla
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('#', textAlign: TextAlign.center),
                ),
                SizedBox(width: 20),
                Expanded(flex: 2, child: Text('Color')),
                SizedBox(width: 20),
                Expanded(flex: 2, child: Text('Código')),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Text('Metraje (${widget.tipoProducto.unidadMedida})'),
                ),
              ],
            ),
          ),

          // Lista de items en formato de tabla
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Número de item
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Color
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _parseColor(item.color.codigoColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.color.nombreColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Código
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.codigo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Input de metraje
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _metrajeControllers[item.id],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              final metraje = double.tryParse(value) ?? 0.0;
                              _actualizarMetraje(item.id, metraje);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Botón para guardar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarStock,
                child: const Text('Guardar Stock'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
