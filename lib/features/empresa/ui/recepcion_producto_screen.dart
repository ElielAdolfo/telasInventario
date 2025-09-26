import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/solicitud_traslado_manager.dart';
import 'package:inventario/features/empresa/models/solicitud_traslado_model.dart';
import 'package:provider/provider.dart';

// Pantalla para confirmar recepción de productos
class RecepcionProductoScreen extends StatefulWidget {
  final SolicitudTraslado solicitud;
  final String empresaId;

  const RecepcionProductoScreen({
    Key? key,
    required this.solicitud,
    required this.empresaId,
  }) : super(key: key);

  @override
  State<RecepcionProductoScreen> createState() =>
      _RecepcionProductoScreenState();
}

class _RecepcionProductoScreenState extends State<RecepcionProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _observacionesController = TextEditingController();
  int _cantidadRecibida = 0;

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.solicitud.cantidadSolicitada.toString();
    _cantidadRecibida = widget.solicitud.cantidadSolicitada;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Recepción')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitud #${widget.solicitud.id.substring(0, 6)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Cantidad enviada: ${widget.solicitud.cantidadSolicitada}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad recibida',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad recibida';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  if (cantidad > widget.solicitud.cantidadSolicitada) {
                    return 'No puede ser mayor a la cantidad enviada';
                  }
                  return null;
                },
                onChanged: (value) {
                  final cantidad = int.tryParse(value);
                  if (cantidad != null) {
                    setState(() {
                      _cantidadRecibida = cantidad;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _devolverProducto(context),
                      child: const Text('Devolver'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmarRecepcion(context),
                      child: const Text('Confirmar Recepción'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarRecepcion(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<SolicitudTrasladoManager>().confirmarRecepcion(
        widget.solicitud.id,
        widget.empresaId,
        'usuario_actual', // Esto debería obtenerse del sistema de autenticación
        _cantidadRecibida,
        _observacionesController.text.isNotEmpty
            ? _observacionesController.text
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recepción confirmada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar recepción: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _devolverProducto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devolver Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Está seguro de devolver este producto?'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Motivo de devolución',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Guardar el motivo
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Aquí iría la lógica para devolver el producto
            },
            child: const Text('Devolver'),
          ),
        ],
      ),
    );
  }
}
