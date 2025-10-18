// lib/features/stock/ui/asignar_stock_tienda_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/logic/solicitud_traslado_manager.dart';
import 'package:inventario/features/empresa/logic/stock_empresa_manager.dart';
import 'package:inventario/features/empresa/logic/tipo_producto_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:inventario/features/empresa/models/solicitud_traslado_model.dart';
import 'package:inventario/features/empresa/models/stock_empresa_model.dart';
import 'package:inventario/features/empresa/models/tipo_producto_model.dart';
import 'package:provider/provider.dart';
import '../../empresa/models/tienda_model.dart';
import '../../empresa/logic/tienda_manager.dart';

class AsignarStockTiendaScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const AsignarStockTiendaScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<AsignarStockTiendaScreen> createState() =>
      _AsignarStockTiendaScreenState();
}

class _AsignarStockTiendaScreenState extends State<AsignarStockTiendaScreen> {
  // Variables para la selección de producto y color
  TipoProducto? _productoSeleccionado;
  ColorProducto? _colorSeleccionado;
  StockEmpresa? _stockSeleccionado;

  // Variables para la tienda
  Tienda? _tiendaSeleccionada;

  // Variables para la lista de productos a asignar
  List<Map<String, dynamic>> _productosAsignar = [];

  // Controladores para los inputs de cantidad
  Map<String, TextEditingController> _cantidadControllers = {};

  // Controlador para observaciones
  final _observacionesController = TextEditingController();
  late final String? _userId;

  // Controlador para el buscador de código
  final _codigoBusquedaController = TextEditingController();

  // Variable para almacenar el ID del stock encontrado por búsqueda
  String? _stockEncontradoId;

  @override
  void initState() {
    super.initState();

    // Obtener el ID del usuario actual
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;

    // Cargar datos necesarios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TiendaManager>(
        context,
        listen: false,
      ).loadTiendasByEmpresa(widget.empresaId);

      Provider.of<StockEmpresaManager>(
        context,
        listen: false,
      ).loadStockByEmpresa(widget.empresaId);

      Provider.of<TipoProductoManager>(
        context,
        listen: false,
      ).loadTiposProductoByEmpresa(widget.empresaId);

      Provider.of<ColorManager>(context, listen: false).loadColores();
    });
  }

  @override
  void dispose() {
    // Limpiar controladores
    for (var controller in _cantidadControllers.values) {
      controller.dispose();
    }
    _observacionesController.dispose();
    _codigoBusquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asignar Stock - ${widget.empresaNombre}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador por código
            _buildBuscadorPorCodigo(),

            const SizedBox(height: 16),

            // Selector de producto
            _buildProductoSelector(),

            const SizedBox(height: 16),

            // Selector de colores (solo si hay un producto seleccionado)
            if (_productoSeleccionado != null) _buildColorSelector(),

            const SizedBox(height: 16),

            // Lista de productos filtrados por producto y color
            if (_productoSeleccionado != null && _colorSeleccionado != null)
              _buildProductosFiltrados(),

            const SizedBox(height: 16),

            // Lista de productos a asignar
            if (_productosAsignar.isNotEmpty) _buildProductosAsignar(),

            const SizedBox(height: 16),

            // Selector de tienda
            _buildTiendaSelector(),

            const SizedBox(height: 16),

            // Observaciones
            _buildObservacionesField(),

            const SizedBox(height: 24),

            // Botón para asignar
            _buildAsignarButton(),
          ],
        ),
      ),
    );
  }

  // Widget para el buscador por código
  Widget _buildBuscadorPorCodigo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar por código:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codigoBusquedaController,
                decoration: const InputDecoration(
                  labelText: 'Código de producto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _buscarPorCodigo,
              child: const Text('Buscar'),
            ),
          ],
        ),
      ],
    );
  }

  // Método para buscar por código
  void _buscarPorCodigo() {
    final codigo = _codigoBusquedaController.text.trim();
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un código')));
      return;
    }

    final stockManager = Provider.of<StockEmpresaManager>(
      context,
      listen: false,
    );
    final stock = stockManager.buscarStockPorCodigo(codigo);

    if (stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró stock con ese código')),
      );
      return;
    }

    // Obtener el tipo de producto
    final tipoProductoManager = Provider.of<TipoProductoManager>(
      context,
      listen: false,
    );
    final tipoProducto = tipoProductoManager.tiposProducto.firstWhere(
      (tp) => tp.id == stock.idTipoProducto,
      orElse: () => throw Exception('Tipo de producto no encontrado'),
    );

    // Obtener el color si es necesario
    ColorProducto? color;
    if (stock.idColor != null) {
      final colorManager = Provider.of<ColorManager>(context, listen: false);
      color = colorManager.colores.firstWhere(
        (c) => c.id == stock.idColor,
        orElse: () => throw Exception('Color no encontrado'),
      );
    }

    // Establecer los valores
    setState(() {
      _productoSeleccionado = tipoProducto;
      _colorSeleccionado = color;
      _stockEncontradoId = stock.id; // Guardar el ID del stock encontrado
      // Limpiar la lista de productos a asignar y controladores
      _productosAsignar = [];
      _cantidadControllers = {};
    });

    // Limpiar el campo de búsqueda
    _codigoBusquedaController.clear();
  }

  // Widget para seleccionar producto
  Widget _buildProductoSelector() {
    return Consumer<TipoProductoManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (manager.error != null) {
          return Text('Error: ${manager.error}');
        }

        if (manager.tiposProducto.isEmpty) {
          return const Text('No hay productos disponibles');
        }

        return DropdownButtonFormField<TipoProducto>(
          value: _productoSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Seleccionar Producto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: manager.tiposProducto.map((producto) {
            return DropdownMenuItem<TipoProducto>(
              value: producto,
              child: Text(producto.nombre),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _productoSeleccionado = value;
              _colorSeleccionado =
                  null; // Resetear color al cambiar de producto
              _stockEncontradoId = null; // Resetear el stock encontrado
              _productosAsignar = []; // Limpiar lista al cambiar de producto
              _cantidadControllers = {}; // Limpiar controladores
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Seleccione un producto';
            }
            return null;
          },
        );
      },
    );
  }

  // Widget para seleccionar color
  Widget _buildColorSelector() {
    return Consumer<ColorManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (manager.error != null) {
          return Text('Error: ${manager.error}');
        }

        if (manager.colores.isEmpty) {
          return const Text('No hay colores disponibles');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Color:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: manager.colores.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colorSeleccionado = color;
                      _stockEncontradoId = null; // Resetear el stock encontrado
                      _productosAsignar =
                          []; // Limpiar lista al cambiar de color
                      _cantidadControllers = {}; // Limpiar controladores
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(color.codigoColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _colorSeleccionado?.id == color.id
                            ? Colors.black
                            : Colors.grey,
                        width: _colorSeleccionado?.id == color.id ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_colorSeleccionado != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Color seleccionado: ${_colorSeleccionado!.nombreColor}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget para mostrar productos filtrados por producto y color
  Widget _buildProductosFiltrados() {
    return Consumer<StockEmpresaManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (manager.error != null) {
          return Text('Error: ${manager.error}');
        }

        // Filtrar productos por tipo de producto y color
        final productosFiltrados = manager.stockEmpresa.where((stock) {
          return stock.idTipoProducto == _productoSeleccionado!.id &&
              stock.idColor == _colorSeleccionado!.id;
        }).toList();

        if (productosFiltrados.isEmpty) {
          return const Text(
            'No hay stock disponible para este producto y color',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos Disponibles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(0.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                // Encabezado de la tabla
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    _buildTableCell('#', isHeader: true),
                    _buildTableCell('Código', isHeader: true),
                    _buildTableCell('Metros', isHeader: true),
                    _buildTableCell('Añadir', isHeader: true),
                  ],
                ),
                // Filas de productos
                ...productosFiltrados
                    .asMap()
                    .map((index, stock) {
                      // Verificar si esta fila debe ser resaltada
                      final bool esStockEncontrado =
                          stock.id == _stockEncontradoId;

                      // Determinar el estado y color de fondo
                      String estadoTexto = '';
                      Color? colorFondo;
                      Color? colorTexto;

                      if (stock.cantidadReservado > 0) {
                        estadoTexto = 'RESERVADO';
                        colorFondo = Colors.green.withOpacity(
                          0.3,
                        ); // Verde claro para reservado
                        colorTexto = Colors.green[800]; // Texto en verde oscuro
                      } else if (stock.cantidadAprobado > 0) {
                        estadoTexto = 'APROBADO';
                        colorFondo = Colors.red.withOpacity(
                          0.3,
                        ); // Rojo bajo para aprobado
                        colorTexto = Colors.red[800]; // Texto en rojo oscuro
                      } else {
                        // Sin estado (disponible)
                        colorFondo = null; // Blanco
                        colorTexto = null; // Color por defecto
                      }

                      return MapEntry(
                        index,
                        TableRow(
                          decoration: colorFondo != null
                              ? BoxDecoration(color: colorFondo)
                              : null,
                          children: [
                            _buildTableCell('${index + 1}'), // Número de fila
                            _buildTableCell('${stock.codigoUnico}'),
                            // Mostrar metraje con estado entre paréntesis
                            _buildTableCell(
                              '${stock.cantidad} ${estadoTexto.isNotEmpty ? '($estadoTexto)' : ''}',
                              textColor: colorTexto,
                            ),
                            _buildTableCell(
                              'Añadir',
                              isButton: true,
                              onPressed: stock.cantidadDisponible > 0
                                  ? () => _agregarProductoALista(stock)
                                  : null, // Deshabilitar si no hay stock disponible
                            ),
                          ],
                        ),
                      );
                    })
                    .values
                    .toList(),
              ],
            ),
          ],
        );
      },
    );
  }

  // Widget para mostrar la lista de productos a asignar
  Widget _buildProductosAsignar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos a Asignar:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            // Encabezado de la tabla
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                _buildTableCell('Código', isHeader: true),
                _buildTableCell('Producto', isHeader: true),
                _buildTableCell('Metros', isHeader: true),
                _buildTableCell('Acciones', isHeader: true),
              ],
            ),
            // Filas de productos a asignar
            ..._productosAsignar.map((item) {
              final stock = item['stock'] as StockEmpresa;

              // Determinar el estado y color de fondo
              String estadoTexto = '';
              Color? colorFondo;
              Color? colorTexto;

              if (stock.cantidadReservado > 0) {
                estadoTexto = 'RESERVADO';
                colorFondo = Colors.green.withOpacity(
                  0.3,
                ); // Verde claro para reservado
                colorTexto = Colors.green[800]; // Texto en verde oscuro
              } else if (stock.cantidadAprobado > 0) {
                estadoTexto = 'APROBADO';
                colorFondo = Colors.red.withOpacity(
                  0.3,
                ); // Rojo bajo para aprobado
                colorTexto = Colors.red[800]; // Texto en rojo oscuro
              } else {
                // Sin estado (disponible)
                colorFondo = null; // Blanco
                colorTexto = null; // Color por defecto
              }

              return TableRow(
                decoration: colorFondo != null
                    ? BoxDecoration(color: colorFondo)
                    : null,
                children: [
                  _buildTableCell('${stock.codigoUnico}'),
                  _buildTableCell('${item['producto']}'),
                  // Mostrar metraje con estado entre paréntesis
                  _buildTableCell(
                    '${stock.cantidad} ${estadoTexto.isNotEmpty ? '($estadoTexto)' : ''}',
                    textColor: colorTexto,
                  ),
                  _buildTableCell(
                    'Eliminar',
                    isButton: true,
                    color: Colors.red,
                    onPressed: () => _eliminarProductoDeLista(item['id']),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  // Método para construir celdas de tabla
  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isButton = false,
    VoidCallback? onPressed,
    Color? color,
    Color? textColor, // Nuevo parámetro para color de texto
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    if (isButton) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blue,
            minimumSize: const Size(80, 36),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    if (controller != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor, // Aplicar color de texto si se proporciona
        ),
      ),
    );
  }

  // Widget para seleccionar tienda
  Widget _buildTiendaSelector() {
    return Consumer<TiendaManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (manager.error != null) {
          return Text('Error: ${manager.error}');
        }

        if (manager.tiendas.isEmpty) {
          return const Text('No hay tiendas disponibles');
        }

        return DropdownButtonFormField<Tienda>(
          value: _tiendaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Seleccionar Tienda',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.store),
          ),
          items: manager.tiendas.map((tienda) {
            return DropdownMenuItem<Tienda>(
              value: tienda,
              child: Text(tienda.nombre),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _tiendaSeleccionada = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Seleccione una tienda';
            }
            return null;
          },
        );
      },
    );
  }

  // Widget para observaciones
  Widget _buildObservacionesField() {
    return TextFormField(
      controller: _observacionesController,
      decoration: const InputDecoration(
        labelText: 'Observaciones (opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  // Widget para el botón de asignar
  Widget _buildAsignarButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _asignarStock,
        child: const Text('Realizar Pedido'),
      ),
    );
  }

  // Método para agregar un producto a la lista
  void _agregarProductoALista(StockEmpresa stock) {
    // Verificar si el producto ya está en la lista
    final yaExiste = _productosAsignar.any((item) => item['id'] == stock.id);

    if (yaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este producto ya está en la lista'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _productosAsignar.add({
        'id': stock.id,
        'producto':
            '${_productoSeleccionado!.nombre} - ${_colorSeleccionado?.nombreColor ?? ''}',
        'stock':
            stock, // Guardamos el stock completo para acceder a sus propiedades
      });
    });
  }

  // Método para eliminar un producto de la lista
  void _eliminarProductoDeLista(String id) {
    setState(() {
      _productosAsignar.removeWhere((item) => item['id'] == id);
      _cantidadControllers.remove(id);
    });
  }

  // MÉTODO MODIFICADO: Para realizar el pedido con correlativo
  void _asignarStock() async {
    if (_tiendaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una tienda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_productosAsignar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar productos al pedido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<String> errores = [];
      int exitosos = 0;
      String? correlativoGenerado; // Para almacenar el correlativo generado

      // Crear una solicitud por cada producto
      for (var item in _productosAsignar) {
        final stock = item['stock'] as StockEmpresa;

        // MODIFICADO: Crear la solicitud con estado RESERVADO en lugar de APROBADO
        // Y copiar todos los datos relevantes del StockEmpresa
        final solicitud = SolicitudTraslado(
          id: '',
          idEmpresa: widget.empresaId,
          idTienda: _tiendaSeleccionada!.id,
          idStockOrigen: stock.id,
          tipoSolicitud: 'EMPRESA_A_TIENDA',
          cantidadSolicitada:
              1, // Siempre será 1 porque cada código es una unidad
          cantidad: stock.cantidad, // Metraje del producto
          estado: 'RESERVADO', // Estado inicial según el nuevo flujo
          fechaSolicitud: DateTime.now(),
          motivo: _observacionesController.text.isNotEmpty
              ? _observacionesController.text
              : null,
          solicitadoPor:
              _userId ?? 'usuario_actual', // Usar el ID del usuario actual
          // No se establece aprobadoPor ni fechaAprobacion hasta que se apruebe

          // Campos copiados de StockEmpresa para mantener un registro histórico
          categoria: stock.categoria,
          nombre: stock.nombre,
          unidadMedida: stock.unidadMedida,
          unidadMedidaSecundaria: stock.unidadMedidaSecundaria,
          permiteVentaParcial: stock.permiteVentaParcial,
          requiereColor: stock.requiereColor,
          precioCompra: stock.precioCompra,
          precioVentaMenor: stock.precioVentaMenor,
          precioVentaMayor: stock.precioVentaMayor,
          precioPaquete: stock.precioPaquete, // Nuevo campo: precio por paquete
          lote: stock.lote,
          fechaVencimiento: stock.fechaVencimiento,
          colorNombre: _colorSeleccionado?.nombreColor,
          colorCodigo: _colorSeleccionado?.codigoColor,
          codigoUnico: stock.codigoUnico, // Agregar el código único
          // Campos de auditoría
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: _userId,
          updatedBy: _userId,
          deletedAt: null,
          deletedBy: null,
          idMoneda: stock.idMoneda,
          tipoCambio: stock.tipoCambio,
        );

        final resultado = await context
            .read<SolicitudTrasladoManager>()
            .createSolicitudTraslado(solicitud);

        if (resultado) {
          exitosos++;

          // Obtener el correlativo de la última solicitud creada
          if (correlativoGenerado == null) {
            // Obtener la lista actualizada de solicitudes
            await context
                .read<SolicitudTrasladoManager>()
                .loadSolicitudesByEmpresa(widget.empresaId);

            final solicitudes = context
                .read<SolicitudTrasladoManager>()
                .solicitudes;

            if (solicitudes.isNotEmpty) {
              // Ordenar por fecha de solicitud descendente para obtener la más reciente
              solicitudes.sort(
                (a, b) => b.fechaSolicitud.compareTo(a.fechaSolicitud),
              );
              correlativoGenerado = solicitudes.first.correlativo;
            }
          }
        } else {
          // Obtenemos el error del manager para mostrarlo
          final error = context.read<SolicitudTrasladoManager>().error;
          errores.add(
            'Error al procesar ${item['producto']}: ${error ?? "Error desconocido"}',
          );
        }
      }

      Navigator.pop(context);

      if (mounted) {
        if (errores.isEmpty && exitosos > 0) {
          // Si no hubo errores y al menos uno fue exitoso
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pedido realizado correctamente. Correlativo: $correlativoGenerado. $exitosos productos procesados.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (exitosos > 0) {
          // Si hubo errores pero también éxitos
          String mensajeErrores = errores.join('\n');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Pedido parcialmente completado ($exitosos/${_productosAsignar.length})',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (correlativoGenerado != null)
                    Text(
                      'Correlativo: $correlativoGenerado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),
                  Text(mensajeErrores),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Si todos fallaron
          String mensajeErrores = errores.join('\n');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error al realizar el pedido'),
              content: Text(mensajeErrores),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar el pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para parsear color
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
