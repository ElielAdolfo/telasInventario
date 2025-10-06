// lib/features/empresa/ui/detalle_solicitud_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/solicitud_traslado_manager.dart';
import 'package:inventario/features/empresa/logic/stock_empresa_manager.dart';
import 'package:inventario/features/empresa/logic/tipo_producto_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/models/solicitud_traslado_model.dart';
import 'package:inventario/features/empresa/models/stock_empresa_model.dart';
import 'package:inventario/features/empresa/models/tipo_producto_model.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:provider/provider.dart';

class DetalleSolicitudScreen extends StatefulWidget {
  final SolicitudTraslado solicitud;
  final String empresaId;

  const DetalleSolicitudScreen({
    super.key,
    required this.solicitud,
    required this.empresaId,
  });

  @override
  State<DetalleSolicitudScreen> createState() => _DetalleSolicitudScreenState();
}

class _DetalleSolicitudScreenState extends State<DetalleSolicitudScreen> {
  bool _mounted = true;
  late SolicitudTraslado _solicitud;
  StockEmpresa? _stock;
  TipoProducto? _tipoProducto;
  ColorProducto? _color;
  bool _editando = false;
  bool _aprobacionBloqueada = false;
  final _correccionController = TextEditingController();

  // Guardar una referencia al contexto global para usarlo en operaciones asíncronas
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  // Managers para cargar los datos
  final TipoProductoManager _tipoProductoManager = TipoProductoManager();
  final ColorManager _colorManager = ColorManager();

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _solicitud = widget.solicitud;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _cargarDetalles();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _correccionController.dispose();
    super.dispose();
  }

  Future<void> _cargarDetalles() async {
    if (!_mounted) return;

    try {
      // Mostrar indicador de carga
      setState(() {});

      // Cargar el stock asociado
      final stockManager = context.read<StockEmpresaManager>();
      await stockManager.loadStockByEmpresa(widget.empresaId);

      if (!_mounted) return;

      final stocks = stockManager.stockEmpresa;
      _stock = stocks.firstWhere(
        (s) => s.id == widget.solicitud.idStockOrigen,
        orElse: () => StockEmpresa.empty(),
      );

      // Cargar el tipo de producto
      await _tipoProductoManager.loadTiposProductoByEmpresa(widget.empresaId);

      if (!_mounted) return;

      _tipoProducto = _tipoProductoManager.tiposProducto.firstWhere(
        (tp) => tp.id == _stock?.idTipoProducto,
        orElse: () => TipoProducto.empty(),
      );

      // Cargar el color
      await _colorManager.loadColores();

      if (!_mounted) return;

      _color = _colorManager.colores.firstWhere(
        (c) => c.id == _stock?.idColor,
        orElse: () => ColorProducto.empty(),
      );

      if (_mounted) {
        setState(() {});
      }
    } catch (e) {
      if (_mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_mounted) {
            _mostrarError('Error al cargar detalles: $e');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detalle del Pedido ${_solicitud.correlativo ?? ""}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información general del pedido
              _buildInformacionGeneral(),

              const SizedBox(height: 24),

              // Lista de productos
              _buildListaProductos(),

              const SizedBox(height: 24),

              // Botones de acción
              _buildBotonesAccion(),

              const SizedBox(height: 24),

              // Formulario de corrección (si está editando)
              if (_editando) _buildFormularioCorreccion(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformacionGeneral() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Número de Pedido:',
              _solicitud.correlativo ?? "Sin asignar",
            ),
            _buildInfoRow('Estado:', _solicitud.estado),
            _buildInfoRow(
              'Tipo:',
              _solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
                  ? 'Asignación de empresa'
                  : 'Solicitud a empresa',
            ),
            _buildInfoRow(
              'Fecha de Solicitud:',
              _formatDate(_solicitud.fechaSolicitud),
            ),
            if (_solicitud.fechaAprobacion != null)
              _buildInfoRow(
                'Fecha de Aprobación:',
                _formatDate(_solicitud.fechaAprobacion),
              ),
            if (_solicitud.motivo != null)
              _buildInfoRow('Motivo:', _solicitud.motivo!),
            if (_solicitud.motivoRechazo != null)
              _buildInfoRow('Motivo de Rechazo:', _solicitud.motivoRechazo!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildListaProductos() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista de productos
            _buildProductoItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Fila para categoría y botón editar (solo si está en estado RESERVADO)
          Row(
            children: [
              // Categoría
              Expanded(
                child: Text(
                  'Categoría: ${_tipoProducto?.categoria ?? "Cargando..."}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Botón Editar - SOLO visible si está en estado RESERVADO
              if (_solicitud.estado == 'RESERVADO')
                ElevatedButton(
                  onPressed: () {
                    if (_mounted) {
                      setState(() {
                        _editando = true;
                        _aprobacionBloqueada = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 36),
                  ),
                  child: const Text('Editar'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Fila para tipo de tela
          Row(
            children: [
              // Tipo de tela
              Expanded(
                child: Text(
                  'Tipo de tela: ${_tipoProducto?.nombre ?? "Cargando..."}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Fila para color y cantidad
          Row(
            children: [
              // Nombre del color
              Expanded(
                child: Text('Color: ${_color?.nombreColor ?? "Cargando..."}'),
              ),

              // Color (esfera)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _parseColor(_color?.codigoColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),

              const SizedBox(width: 16),

              // Cantidad a recibir
              Text(
                'Cantidad: ${_solicitud.cantidadSolicitada}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Column(
      children: [
        // Botones según el estado
        switch (_solicitud.estado) {
          'RESERVADO' => _buildBotonesReservado(),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  Widget _buildBotonesReservado() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón Aprobar
        ElevatedButton.icon(
          onPressed: _aprobacionBloqueada ? null : () => _aprobarSolicitud(),
          icon: const Icon(Icons.check),
          label: const Text('Aprobar Solicitud'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(120, 48),
          ),
        ),

        // Botón Corregir (solo visible si está editando)
        if (_editando)
          ElevatedButton.icon(
            onPressed: () => _mostrarFormularioCorreccion(),
            icon: const Icon(Icons.edit),
            label: const Text('Corregir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(120, 48),
            ),
          ),
      ],
    );
  }

  Widget _buildFormularioCorreccion() {
    return Card(
      elevation: 3,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Corrección del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _correccionController,
              decoration: const InputDecoration(
                labelText: 'Describa la corrección necesaria',
                border: OutlineInputBorder(),
                hintText: 'Ej: La cantidad solicitada no es correcta',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (_mounted) {
                      setState(() {
                        _editando = false;
                        _aprobacionBloqueada = false;
                        _correccionController.clear();
                      });
                    }
                  },
                  child: const Text('Cancelar'),
                ),

                const SizedBox(width: 16),

                ElevatedButton(
                  onPressed: _enviarCorreccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Enviar Corrección'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _aprobarSolicitud() {
    if (!_mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Solicitud'),
        content: Text(
          '¿Está seguro de aprobar esta solicitud por ${_solicitud.cantidadSolicitada} unidades?\n\n'
          'Esta acción creará automáticamente el stock en la tienda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Verificar si el widget sigue montado antes de continuar
              if (!mounted) return;

              // Mostrar indicador de carga
              BuildContext? dialogContext;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  dialogContext = context;
                  return const Center(child: CircularProgressIndicator());
                },
              );

              try {
                final success = await context
                    .read<SolicitudTrasladoManager>()
                    .aprobarSolicitud(
                      _solicitud.id,
                      widget.empresaId,
                      'usuario_actual', // Esto debería obtenerse del sistema de autenticación
                    );

                // Verificar si el widget sigue montado antes de continuar
                if (!mounted) return;

                // Cerrar indicador de carga de forma segura
                if (dialogContext != null && mounted) {
                  Navigator.pop(dialogContext!);
                }

                if (success) {
                  if (mounted) {
                    // Actualizar la solicitud local
                    setState(() {
                      _solicitud = _solicitud.copyWith(
                        estado: 'APROBADO',
                        aprobadoPor: 'usuario_actual',
                        fechaAprobacion: DateTime.now(),
                      );
                    });

                    _mostrarMensajeExito(
                      'Solicitud aprobada correctamente. Stock creado en la tienda.',
                    );
                  }
                } else {
                  if (mounted) {
                    _mostrarError(
                      'Error al aprobar solicitud: ${context.read<SolicitudTrasladoManager>().error}',
                    );
                  }
                }
              } catch (e) {
                // Manejar cualquier excepción que pueda ocurrir
                if (!mounted) return;

                // Cerrar indicador de carga de forma segura
                if (dialogContext != null && mounted) {
                  Navigator.pop(dialogContext!);
                }

                if (mounted) {
                  _mostrarError('Error inesperado: $e');
                }
              }
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar información en el modal
  Widget _buildInfoModal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _mostrarFormularioCorreccion() {
    if (_mounted) {
      setState(() {
        _editando = true;
      });
    }
  }

  void _enviarCorreccion() {
    if (!_mounted) return;

    if (_correccionController.text.isEmpty) {
      _mostrarError('Debe describir la corrección necesaria');
      return;
    }

    // Aquí implementarías la lógica para enviar la corrección a la empresa
    // Por ahora, solo mostramos un mensaje
    _mostrarMensajeAdvertencia(
      'Corrección enviada a la empresa para su revisión',
    );

    if (_mounted) {
      setState(() {
        _editando = false;
        _aprobacionBloqueada = false;
        _correccionController.clear();
      });
    }
  }

  void _mostrarError(String mensaje) {
    if (!_mounted) return;
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarMensajeExito(String mensaje) {
    if (!_mounted) return;
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  void _mostrarMensajeAdvertencia(String mensaje) {
    if (!_mounted) return;
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.orange),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
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
