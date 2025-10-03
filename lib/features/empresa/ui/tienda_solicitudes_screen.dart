// lib/features/empresa/ui/tienda_solicitudes_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/solicitud_traslado_manager.dart';
import 'package:inventario/features/empresa/models/solicitud_traslado_model.dart';
import 'package:inventario/features/empresa/models/tienda_model.dart';
import 'package:inventario/features/empresa/ui/detalle_solicitud_screen.dart';
import 'package:provider/provider.dart';

class TiendaSolicitudesScreen extends StatefulWidget {
  final Tienda tienda;
  final String empresaId;

  const TiendaSolicitudesScreen({
    super.key,
    required this.tienda,
    required this.empresaId,
  });

  @override
  State<TiendaSolicitudesScreen> createState() =>
      _TiendaSolicitudesScreenState();
}

class _TiendaSolicitudesScreenState extends State<TiendaSolicitudesScreen> {
  bool _mounted = true;
  late final String? _userId;

  @override
  void initState() {
    super.initState();
    _mounted = true;

    // Obtener el ID del usuario actual
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;

    // Cargar solicitudes pendientes de la tienda
    Future.microtask(() {
      _loadSolicitudes();
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadSolicitudes() async {
    if (!_mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_mounted) return;
      await context.read<SolicitudTrasladoManager>().loadSolicitudesByTienda(
        widget.tienda.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solicitudes de ${widget.tienda.nombre}')),
      body: _buildSolicitudesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSolicitudes,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSolicitudesList() {
    return Consumer<SolicitudTrasladoManager>(
      builder: (context, manager, child) {
        if (manager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (manager.error != null) {
          return Center(child: Text('Error: ${manager.error}'));
        }

        // Filtrar solicitudes para esta tienda específica
        final solicitudesTienda = manager.solicitudes
            .where((s) => s.idTienda == widget.tienda.id)
            .toList();

        if (solicitudesTienda.isEmpty) {
          return const Center(
            child: Text('No hay solicitudes para esta tienda'),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadSolicitudes,
          child: ListView.builder(
            itemCount: solicitudesTienda.length,
            itemBuilder: (context, index) {
              final solicitud = solicitudesTienda[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getEstadoColor(solicitud.estado),
                        child: Icon(
                          _getEstadoIcon(solicitud.estado),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Pedido: ${solicitud.correlativo ?? "Sin correlativo"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
                                ? 'Asignación de empresa'
                                : 'Solicitud a empresa',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Producto: ${solicitud.nombre}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cantidad: ${solicitud.cantidadSolicitada}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: _buildEstadoBadge(solicitud.estado),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Botón Ver Detalles
                          ElevatedButton.icon(
                            onPressed: () => _verDetalles(context, solicitud),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Ver Detalles'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 36),
                            ),
                          ),

                          // Botón Aprobar (solo para solicitudes RESERVADAS)
                          if (solicitud.estado == 'RESERVADO')
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _aprobarSolicitud(context, solicitud),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Aprobar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(120, 36),
                              ),
                            ),

                          // Botón Cancelar (solo para solicitudes RESERVADAS)
                          if (solicitud.estado == 'RESERVADO')
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _cancelarSolicitud(context, solicitud),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(120, 36),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color color;
    String text;

    switch (estado) {
      case 'RESERVADO':
        color = Colors.orange;
        text = 'Reservado';
        break;
      case 'APROBADO':
        color = Colors.green;
        text = 'Aprobado';
        break;
      case 'RECHAZADO':
        color = Colors.red;
        text = 'Rechazado';
        break;
      case 'EN_TRASLADO':
        color = Colors.blue;
        text = 'En Tránsito';
        break;
      case 'RECIBIDO':
        color = Colors.purple;
        text = 'Recibido';
        break;
      case 'DEVUELTO':
        color = Colors.brown;
        text = 'Devuelto';
        break;
      default:
        color = Colors.grey;
        text = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'RESERVADO':
        return Colors.orange;
      case 'APROBADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      case 'EN_TRASLADO':
        return Colors.blue;
      case 'RECIBIDO':
        return Colors.purple;
      case 'DEVUELTO':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'RESERVADO':
        return Icons.watch_later;
      case 'APROBADO':
        return Icons.check_circle;
      case 'RECHAZADO':
        return Icons.cancel;
      case 'EN_TRASLADO':
        return Icons.local_shipping;
      case 'RECIBIDO':
        return Icons.inventory_2;
      case 'DEVUELTO':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  void _verDetalles(BuildContext context, SolicitudTraslado solicitud) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleSolicitudScreen(
          solicitud: solicitud,
          empresaId: widget.empresaId,
        ),
      ),
    ).then((_) {
      // Recargar solicitudes al volver solo si el widget sigue montado
      if (_mounted) {
        _loadSolicitudes();
      }
    });
  }

  void _aprobarSolicitud(BuildContext context, SolicitudTraslado solicitud) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Solicitud'),
        content: Text(
          '¿Está seguro de aprobar esta solicitud por ${solicitud.cantidadSolicitada} unidades?\n\n'
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

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!_mounted) return;

                final success = await context
                    .read<SolicitudTrasladoManager>()
                    .aprobarSolicitud(
                      solicitud.id,
                      widget.empresaId,
                      _userId ??
                          'usuario_actual', // Esto debería obtenerse del sistema de autenticación
                    );

                if (!_mounted) return;

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Solicitud aprobada correctamente. Stock creado en la tienda.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadSolicitudes();
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al aprobar solicitud: ${context.read<SolicitudTrasladoManager>().error}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _cancelarSolicitud(BuildContext context, SolicitudTraslado solicitud) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: const Text('¿Está seguro de cancelar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await context.read<SolicitudTrasladoManager>().rechazarSolicitud(
                solicitud.id,
                widget.empresaId,
                'Cancelado por la tienda',
                _userId ?? 'usuario_actual',
              );

              // Cerrar indicador de carga solo si el diálogo sigue abierto
              if (_mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              // Recargar después de cancelar y mostrar SnackBar solo si el widget sigue montado
              if (_mounted) {
                _loadSolicitudes();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Solicitud cancelada correctamente'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }
}
