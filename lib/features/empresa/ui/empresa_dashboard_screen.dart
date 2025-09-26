import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/tienda_model.dart';
import 'package:inventario/features/empresa/services/tienda_service.dart';
import 'package:inventario/features/empresa/ui/empresa_form_screen.dart';
import 'package:inventario/features/empresa/ui/tienda_list_screen.dart';
import 'package:provider/provider.dart';
import '../models/empresa_model.dart';
import '../logic/empresa_manager.dart';
import '../services/empresa_service.dart';

class EmpresaDashboardScreen extends StatefulWidget {
  final Empresa empresa;
  const EmpresaDashboardScreen({Key? key, required this.empresa})
    : super(key: key);

  @override
  _EmpresaDashboardScreenState createState() => _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  final EmpresaService _service = EmpresaService();
  final TiendaService _tiendaService = TiendaService();
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  List<Tienda> _tiendas = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Mostrar indicador de carga al inicio
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar tiendas de la empresa
      _tiendas = await _tiendaService.getTiendasByEmpresa(widget.empresa.id);
      // Simulación de datos para productos y ventas
      await Future.delayed(const Duration(seconds: 1));

      // Actualizar estado solo cuando todos los datos estén listos
      setState(() {
        _dashboardData = {
          'totalTiendas': _tiendas.length,
          'totalProductos': 25,
          'ventasMes': 15230.50,
          'rollosStock': 120,
          'productosMasVendidos': [
            {'nombre': 'Algodón Premium', 'ventas': 150},
            {'nombre': 'Lino Elegante', 'ventas': 120},
            {'nombre': 'Seda Natural', 'ventas': 95},
          ],
          'tiendasActivas': _tiendas.map((tienda) {
            return {
              'nombre': tienda.nombre,
              'ventas': 8500.30,
              'isWarehouse': tienda.isWarehouse,
            };
          }).toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
      // Ocultar indicador de carga incluso si hay error
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${widget.empresa.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmpresaInfoCard(),

                    const SizedBox(height: 24),
                    _buildTiendasSection(),
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildProductsChart(),
                    const SizedBox(height: 24),
                    _buildStoresChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmpresaInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.empresa.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.location_on,
                        widget.empresa.direccion,
                      ),
                      _buildInfoRow(Icons.phone, widget.empresa.telefono),
                      _buildInfoRow(Icons.receipt, widget.empresa.ruc),
                    ],
                  ),
                ),
                if (widget.empresa.logoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.empresa.logoUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Tiendas',
                _dashboardData['totalTiendas'].toString(),
                Icons.store,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Productos',
                _dashboardData['totalProductos'].toString(),
                Icons.category,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Ventas del Mes',
                'S/ ${(_dashboardData['ventasMes'] as num?)?.toStringAsFixed(2) ?? "0.00"}',
                Icons.attach_money,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Rollos en Stock',
                _dashboardData['rollosStock'].toString(),
                Icons.inventory_2,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsChart() {
    final productos = (_dashboardData['productosMasVendidos'] as List?) ?? [];
    if (productos.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos más vendidos',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: productos.map((producto) {
                final ventas = producto['ventas'] as int? ?? 0;
                final maxVentas = productos.fold<int>(
                  0,
                  (max, p) => (p['ventas'] as int? ?? 0) > max
                      ? (p['ventas'] as int)
                      : max,
                );
                final porcentaje = maxVentas > 0 ? ventas / maxVentas : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(producto['nombre'] ?? ''),
                          Text('$ventas unidades'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: porcentaje,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoresChart() {
    final tiendas = (_dashboardData['tiendasActivas'] as List?) ?? [];
    if (tiendas.isEmpty) {
      return const SizedBox();
    }
    final totalVentas = tiendas.fold<double>(
      0,
      (sum, t) => (t['ventas'] as double?) ?? 0 + sum,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ventas por Tienda',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: tiendas.map((tienda) {
                final ventas = (tienda['ventas'] as double?) ?? 0.0;
                final porcentaje = totalVentas > 0 ? ventas / totalVentas : 0.0;
                final isWarehouse = (tienda['isWarehouse'] as bool?) ?? false;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isWarehouse ? Icons.warehouse : Icons.store,
                                size: 16,
                                color: isWarehouse ? Colors.brown : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(tienda['nombre'] ?? ''),
                            ],
                          ),
                          Text('S/ ${ventas.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: porcentaje,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isWarehouse ? Colors.brown : Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmpresaFormScreen(empresa: widget.empresa),
      ),
    ).then((_) {
      // Recargar datos al volver de editar empresa
      _loadDashboardData();
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar ${widget.empresa.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<EmpresaManager>(
                  context,
                  listen: false,
                ).deleteEmpresa(widget.empresa.id);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTiendasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiendas y Almacenes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _navigateToTiendas(context),
              icon: const Icon(Icons.view_list),
              label: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiendas.length > 3 ? 3 : _tiendas.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final tienda = _tiendas[index];
              return ListTile(
                leading: Icon(
                  tienda.isWarehouse ? Icons.warehouse : Icons.store,
                  color: tienda.isWarehouse ? Colors.brown : Colors.blue,
                ),
                title: Text(tienda.nombre),
                subtitle: Text(tienda.direccion),
                trailing: Text(
                  tienda.isWarehouse ? 'Almacén' : 'Tienda',
                  style: TextStyle(
                    color: tienda.isWarehouse ? Colors.brown : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        if (_tiendas.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Mostrando 3 de ${_tiendas.length} tiendas',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToTiendas(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TiendaListScreen(
          empresaId: widget.empresa.id,
          empresaNombre: widget.empresa.nombre,
        ),
      ),
    );

    // Si hubo cambios, recargar datos del dashboard
    if (result == true) {
      _loadDashboardData();
    }
  }
}
