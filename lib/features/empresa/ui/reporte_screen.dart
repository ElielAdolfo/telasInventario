// lib/features/empresa/ui/reporte_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/models/reporte_filtro_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/venta_model.dart';
import '../models/stock_tienda_model.dart';
import '../models/stock_empresa_model.dart';
import '../services/reporte_service.dart';
import '../services/venta_service.dart'; // Importar el VentaService
import '../logic/tienda_manager.dart';
import '../models/tienda_model.dart';

class ReporteScreen extends StatefulWidget {
  final String empresaId;
  final Tienda? tienda;

  const ReporteScreen({super.key, required this.empresaId, this.tienda});

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  final VentaService _ventaService = VentaService(); // Usar VentaService
  final ReporteService _reporteService = ReporteService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ReporteFiltroModel _filtro = ReporteFiltroModel(
    tipoReporte: 'ventas_dia',
    fechaInicio: DateTime.now(),
    fechaFin: DateTime.now(),
  );

  List<Venta> _ventas = [];
  List<StockTienda> _stockTienda = [];
  List<StockEmpresa> _stockEmpresa = [];
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Reportes - ${widget.tienda?.nombre ?? widget.empresaId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirReporte,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _descargarReporte,
          ),
        ],
      ),
      body: Column(
        children: [_buildFiltros(), const Divider(), _buildResultados()],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros de Reporte',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Tipo de reporte
              DropdownButtonFormField<String>(
                value: _filtro.tipoReporte,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Reporte',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'ventas_dia',
                    child: Text('Ventas del Día'),
                  ),
                  DropdownMenuItem(
                    value: 'ventas_rango',
                    child: Text('Ventas por Rango de Fechas'),
                  ),
                  DropdownMenuItem(
                    value: 'stock_tienda',
                    child: Text('Stock Actual de Tienda'),
                  ),
                  DropdownMenuItem(
                    value: 'stock_empresa',
                    child: Text('Stock Actual de Empresa'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _filtro = _filtro.copyWith(tipoReporte: value);
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Filtro de fechas (solo para ventas por rango)
              if (_filtro.tipoReporte == 'ventas_rango')
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarFechaInicio,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Inicio',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(_filtro.fechaInicio ?? DateTime.now()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarFechaFin,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Fin',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(_filtro.fechaFin ?? DateTime.now()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Botón de generar reporte
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generarReporte,
                  child: const Text('Generar Reporte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultados() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Expanded(child: Center(child: Text('Error: $_error')));
    }

    if (_ventas.isNotEmpty) {
      return _buildVentasReport();
    } else if (_stockTienda.isNotEmpty) {
      return _buildStockTiendaReport();
    } else if (_stockEmpresa.isNotEmpty) {
      return _buildStockEmpresaReport();
    } else {
      return const Expanded(
        child: Center(child: Text('No hay datos para mostrar')),
      );
    }
  }

  Widget _buildVentasReport() {
    return Expanded(
      child: Column(
        children: [
          // Resumen de ventas
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Ventas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total de Ventas:'),
                      Text('${_ventas.length}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monto Total:'),
                      Text(
                        '\$${_ventas.fold(0.0, (sum, venta) => sum + venta.total).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de ventas
          Expanded(
            child: ListView.builder(
              itemCount: _ventas.length,
              itemBuilder: (context, index) {
                final venta = _ventas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ExpansionTile(
                    title: Text('Venta #${index + 1}'),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(venta.fechaVenta),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${venta.id}'),
                            Text('Usuario: ${venta.realizadoPor}'),
                            Text('Tienda: ${venta.idTienda}'),
                            Text('Total: \$${venta.total.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...venta.items
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      '${item.nombreProducto} (${item.nombreColor}) - ${item.cantidad} x \$${item.precio.toStringAsFixed(2)} = \$${item.subtotal.toStringAsFixed(2)}',
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTiendaReport() {
    return Expanded(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stock Actual de Tienda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total de Productos:'),
                      Text('${_stockTienda.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _stockTienda.length,
              itemBuilder: (context, index) {
                final stock = _stockTienda[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(stock.nombre),
                    subtitle: Text('Color: ${stock.colorNombre}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stock.cantidadDisponible} ${stock.unidadMedida}',
                        ),
                        Text(
                          '\$${stock.precioVentaMenor.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockEmpresaReport() {
    return Expanded(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stock Actual de Empresa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total de Productos:'),
                      Text('${_stockEmpresa.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _stockEmpresa.length,
              itemBuilder: (context, index) {
                final stock = _stockEmpresa[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(stock.nombre),
                    subtitle: Text('Color: ${stock.idColor}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stock.cantidadDisponible} ${stock.unidadMedida}',
                        ),
                        Text(
                          '\$${stock.precioVentaMenor.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generarReporte() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _ventas = [];
      _stockTienda = [];
      _stockEmpresa = [];
    });

    try {
      switch (_filtro.tipoReporte) {
        case 'ventas_dia':
          if (widget.tienda != null) {
            // Usar VentaService para obtener ventas del día por tienda
            _ventas = await _ventaService.getVentasByTiendaAndDate(
              widget.tienda!.id,
              _filtro.fechaInicio ?? DateTime.now(),
            );
          } else {
            // Si no hay tienda, mostrar error
            _error = 'Debe seleccionar una tienda para ver las ventas del día';
          }
          break;

        case 'ventas_rango':
          // Usar VentaService para obtener ventas por rango de fechas
          if (widget.tienda != null) {
            _ventas = await _ventaService.getVentasByTiendaAndDate(
              widget.tienda!.id,
              _filtro.fechaInicio ?? DateTime.now(),
            );

            // Filtrar por rango de fechas
            DateTime fechaFin = _filtro.fechaFin ?? DateTime.now();
            _ventas = _ventas
                .where(
                  (venta) =>
                      venta.fechaVenta.isBefore(
                        fechaFin.add(const Duration(days: 1)),
                      ) ||
                      venta.fechaVenta.isAtSameMomentAs(fechaFin),
                )
                .toList();
          } else {
            _error =
                'Debe seleccionar una tienda para ver las ventas por rango de fechas';
          }
          break;

        case 'stock_tienda':
          if (widget.tienda != null) {
            _stockTienda = await _reporteService.getStockActualTienda(
              widget.tienda!.id,
            );
          } else {
            _error = 'Debe seleccionar una tienda para ver su stock';
          }
          break;

        case 'stock_empresa':
          _stockEmpresa = await _reporteService.getStockActualEmpresa(
            widget.empresaId,
          );
          break;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _filtro.fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _filtro = _filtro.copyWith(fechaInicio: fecha);
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _filtro.fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _filtro = _filtro.copyWith(fechaFin: fecha);
      });
    }
  }

  void _compartirReporte() {
    String texto = '';

    if (_ventas.isNotEmpty) {
      texto = 'Reporte de Ventas\n\n';
      texto += 'Total de Ventas: ${_ventas.length}\n';
      texto +=
          'Monto Total: \$${_ventas.fold(0.0, (sum, venta) => sum + venta.total).toStringAsFixed(2)}\n\n';

      for (int i = 0; i < _ventas.length; i++) {
        final venta = _ventas[i];
        texto += 'Venta #${i + 1}\n';
        texto +=
            'Fecha: ${DateFormat('yyyy-MM-dd HH:mm').format(venta.fechaVenta)}\n';
        texto += 'Total: \$${venta.total.toStringAsFixed(2)}\n';

        for (final item in venta.items) {
          texto +=
              '  - ${item.nombreProducto} (${item.nombreColor}): ${item.cantidad} x \$${item.precio.toStringAsFixed(2)} = \$${item.subtotal.toStringAsFixed(2)}\n';
        }

        texto += '\n';
      }
    } else if (_stockTienda.isNotEmpty) {
      texto = 'Stock Actual de Tienda\n\n';
      texto += 'Total de Productos: ${_stockTienda.length}\n\n';

      for (final stock in _stockTienda) {
        texto +=
            '${stock.nombre} (${stock.colorNombre}): ${stock.cantidadDisponible} ${stock.unidadMedida} - \$${stock.precioVentaMenor.toStringAsFixed(2)}\n';
      }
    } else if (_stockEmpresa.isNotEmpty) {
      texto = 'Stock Actual de Empresa\n\n';
      texto += 'Total de Productos: ${_stockEmpresa.length}\n\n';

      for (final stock in _stockEmpresa) {
        texto +=
            '${stock.nombre} (${stock.idColor}): ${stock.cantidadDisponible} ${stock.unidadMedida} - \$${stock.precioVentaMenor.toStringAsFixed(2)}\n';
      }
    }

    if (texto.isNotEmpty) {
      Share.share(texto);
    }
  }

  void _descargarReporte() {
    // Aquí podrías implementar la descarga en PDF o Excel
    // Por ahora, mostraremos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de descarga en desarrollo')),
    );
  }
}
