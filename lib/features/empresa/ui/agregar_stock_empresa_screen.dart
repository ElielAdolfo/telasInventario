// lib/features/stock/ui/agregar_stock_empresa_screen.dart
import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/logic/moneda_manager.dart';
import 'package:inventario/features/empresa/logic/tipo_producto_manager.dart';
import 'package:inventario/features/empresa/models/bolsa_colores_model.dart';
import 'package:inventario/features/empresa/models/color_con_cantidad_model.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:inventario/features/empresa/models/moneda_model.dart';
import 'package:inventario/features/empresa/models/tipo_producto_model.dart';
import 'package:inventario/features/empresa/services/bolsa_colores_service.dart';
import 'package:inventario/features/empresa/ui/detalle_stock_screen.dart';
import 'package:provider/provider.dart';

class AgregarStockEmpresaScreen extends StatefulWidget {
  final String idEmpresa;
  final String empresaNombre;
  final TipoProducto? tipoProducto;

  const AgregarStockEmpresaScreen({
    super.key,
    required this.idEmpresa,
    required this.empresaNombre,
    this.tipoProducto,
  });

  @override
  State<AgregarStockEmpresaScreen> createState() =>
      _AgregarStockEmpresaScreenState();
}

class _AgregarStockEmpresaScreenState extends State<AgregarStockEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _precioCompraController = TextEditingController();
  final _precioVentaMenorController = TextEditingController();
  final _precioVentaMayorController = TextEditingController();
  final _precioPaqueteController = TextEditingController();
  final _loteController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();
  late final TextEditingController _cantidadPrioritariaController;
  late final TextEditingController _unidadesController;

  late final String? _userId;
  final BolsaColoresService _bolsaColoresService = BolsaColoresService();

  TipoProducto? _tipoProductoSeleccionado;
  DateTime? _fechaVencimiento;
  List<ColorConCantidad> _coloresSeleccionados = [];
  List<double> _cantidadesPosibles = [];
  double _cantidadPrioritaria = 0;
  int _unidades = 1;

  // Variables para moneda y tipo de cambio
  Moneda? _monedaSeleccionada;
  double _tipoCambio = 1.0;
  double _valorTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _cantidadPrioritariaController = TextEditingController(
      text: _cantidadPrioritaria.toString(),
    );
    _unidadesController = TextEditingController(text: _unidades.toString());

    _tipoProductoSeleccionado = widget.tipoProducto;

    if (_tipoProductoSeleccionado != null) {
      _cargarDatosProducto(_tipoProductoSeleccionado!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TipoProductoManager>(
        context,
        listen: false,
      ).loadTiposProductoByEmpresa(widget.idEmpresa);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ColorManager>(context, listen: false).loadColores();
    });
    // Cargar monedas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MonedaManager>(context, listen: false).loadMonedas();
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;

    // Configurar listener para el campo de precio de compra
    _precioCompraController.addListener(_calcularValorTotal);
  }

  @override
  void dispose() {
    _precioCompraController.dispose();
    _precioVentaMenorController.dispose();
    _precioVentaMayorController.dispose();
    _precioPaqueteController.dispose();
    _loteController.dispose();
    _observacionesController.dispose();
    _fechaVencimientoController.dispose();
    _cantidadPrioritariaController.dispose();
    _unidadesController.dispose();
    super.dispose();
  }

  void _cargarDatosProducto(TipoProducto producto) {
    setState(() {
      _tipoProductoSeleccionado = producto;
      _cantidadesPosibles = List<double>.from(producto.cantidadesPosibles);
      _cantidadPrioritaria = producto.cantidadPrioritaria;
      _cantidadPrioritariaController.text = producto.cantidadPrioritaria
          .toString();

      _precioCompraController.text = producto.precioCompraDefault.toString();
      _precioVentaMenorController.text = producto.precioVentaDefaultMenor
          .toString();
      _precioVentaMayorController.text = producto.precioVentaDefaultMayor
          .toString();

      if (producto.precioPaquete != null) {
        _precioPaqueteController.text = producto.precioPaquete.toString();
      } else {
        _precioPaqueteController.clear();
      }
    });
  }

  Future<void> _selectFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
        _fechaVencimientoController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _guardarStock(String? userId) async {
    if (!_formKey.currentState!.validate()) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tipoProductoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un tipo de producto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar colores si el producto lo requiere
    if (_tipoProductoSeleccionado!.requiereColor &&
        _coloresSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un color'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navegar a la pantalla de detalle con los datos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleStockScreen(
          idEmpresa: widget.idEmpresa,
          empresaNombre: widget.empresaNombre,
          tipoProducto: _tipoProductoSeleccionado!,
          coloresSeleccionados: _coloresSeleccionados,
          userId: userId,
          lote: _loteController.text.isNotEmpty ? _loteController.text : null,
          fechaVencimiento: _fechaVencimiento,
          observaciones: _observacionesController.text.isNotEmpty
              ? _observacionesController.text
              : null,
          precioCompra: double.tryParse(_precioCompraController.text) ?? 0.0,
          precioVentaMenor:
              double.tryParse(_precioVentaMenorController.text) ?? 0.0,
          precioVentaMayor:
              double.tryParse(_precioVentaMayorController.text) ?? 0.0,
          precioPaquete: _precioPaqueteController.text.isNotEmpty
              ? double.tryParse(_precioPaqueteController.text)
              : null,
          moneda: _monedaSeleccionada,
          tipoCambio: _tipoCambio,
        ),
      ),
    );
  }

  void _agregarColor(ColorProducto color) {
    if (_cantidadPrioritaria <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar una cantidad válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_unidades <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar una cantidad de unidades válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener valores por defecto de los campos globales
    final precioCompra = double.tryParse(_precioCompraController.text) ?? 0.0;
    final precioVentaMenor =
        double.tryParse(_precioVentaMenorController.text) ?? 0.0;
    final precioVentaMayor =
        double.tryParse(_precioVentaMayorController.text) ?? 0.0;
    final precioPaquete = _precioPaqueteController.text.isNotEmpty
        ? double.tryParse(_precioPaqueteController.text)
        : null;

    setState(() {
      _coloresSeleccionados.add(
        ColorConCantidad(
          color: color,
          cantidad: _cantidadPrioritaria,
          unidades: _unidades,
          precioCompra: precioCompra,
          precioVentaMenor: precioVentaMenor,
          precioVentaMayor: precioVentaMayor,
          precioPaquete: precioPaquete,
          lote: _loteController.text.isNotEmpty ? _loteController.text : null,
          fechaVencimiento: _fechaVencimiento,
          observaciones: _observacionesController.text.isNotEmpty
              ? _observacionesController.text
              : null,
        ),
      );

      // Resetear campos después de agregar
      _unidades = 1;
      _unidadesController.text = '1';
    });
  }

  void _actualizarEntradaColor(int index, ColorConCantidad nuevaEntrada) {
    setState(() {
      _coloresSeleccionados[index] = nuevaEntrada;
    });
  }

  void _eliminarEntradaColor(int index) {
    setState(() {
      _coloresSeleccionados.removeAt(index);
    });
  }

  // Método para calcular el valor total
  void _calcularValorTotal() {
    final precioCompra = double.tryParse(_precioCompraController.text) ?? 0.0;
    setState(() {
      _valorTotal = precioCompra * _tipoCambio;
    });
  }

  // Método para manejar el cambio de moneda
  void _cambioMoneda(Moneda? nuevaMoneda) {
    if (nuevaMoneda != null) {
      setState(() {
        _monedaSeleccionada = nuevaMoneda;
        _tipoCambio = nuevaMoneda.tipoCambio;
        // Limpiar el campo de precio de compra
        _precioCompraController.clear();
        // Recalcular el valor total
        _calcularValorTotal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Stock - ${widget.empresaNombre}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tipo de producto
              Consumer<TipoProductoManager>(
                builder: (context, manager, child) {
                  if (manager.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (manager.error != null) {
                    return Text('Error: ${manager.error}');
                  }

                  if (manager.tiposProducto.isEmpty) {
                    return const Text('No hay tipos de producto disponibles');
                  }

                  return DropdownButtonFormField<TipoProducto>(
                    value: _tipoProductoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Producto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: manager.tiposProducto.map((tipo) {
                      return DropdownMenuItem<TipoProducto>(
                        value: tipo,
                        child: Text(tipo.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _cargarDatosProducto(value);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Seleccione un tipo de producto';
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Mostrar cantidades posibles si hay un producto seleccionado y permite venta parcial
              if (_tipoProductoSeleccionado != null &&
                  _tipoProductoSeleccionado!.permiteVentaParcial) ...[
                // Campo de unidades (rollos)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unidadesController,
                        decoration: InputDecoration(
                          labelText: 'Unidades (rollos)',
                          hintText: 'Número de rollos',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final unidades = int.tryParse(value) ?? 1;
                          setState(() {
                            _unidades = unidades;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el número de unidades';
                          }
                          final unidades = int.tryParse(value);
                          if (unidades == null || unidades <= 0) {
                            return 'Ingrese una cantidad válida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            final unidades = _unidades + 1;
                            setState(() {
                              _unidades = unidades;
                              _unidadesController.text = unidades.toString();
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            if (_unidades > 1) {
                              final unidades = _unidades - 1;
                              setState(() {
                                _unidades = unidades;
                                _unidadesController.text = unidades.toString();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.remove, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Cantidades Posibles (metros por rollo):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _cantidadesPosibles.map((cantidad) {
                    return InputChip(
                      label: Text('$cantidad'),
                      onPressed: () {
                        setState(() {
                          _cantidadPrioritaria = cantidad;
                          _cantidadPrioritariaController.text = cantidad
                              .toString();
                        });
                      },
                      selected: _cantidadPrioritaria == cantidad,
                      selectedColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Input de cantidad con botones de incremento/decremento
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cantidadPrioritariaController,
                        decoration: InputDecoration(
                          labelText:
                              'Cantidad por ${_tipoProductoSeleccionado!.unidadMedida}',
                          hintText:
                              'Ej: 20 ${_tipoProductoSeleccionado!.unidadMedida.toLowerCase()} por rollo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final cantidad = double.tryParse(value) ?? 1;
                          setState(() {
                            _cantidadPrioritaria = cantidad;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la cantidad por ${_tipoProductoSeleccionado!.unidadMedida}';
                          }
                          final cantidad = int.tryParse(value);
                          if (cantidad == null || cantidad <= 0) {
                            return 'Ingrese una cantidad válida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            final cantidad = _cantidadPrioritaria + 1;
                            setState(() {
                              _cantidadPrioritaria = cantidad;
                              _cantidadPrioritariaController.text = cantidad
                                  .toString();
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            if (_cantidadPrioritaria > 1) {
                              final cantidad = _cantidadPrioritaria - 1;
                              setState(() {
                                _cantidadPrioritaria = cantidad;
                                _cantidadPrioritariaController.text = cantidad
                                    .toString();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.remove, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Campo Precio de Compra con validaciones
              Divider(),
              Text(
                'Precio:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),

              // Selector de moneda y campo de precio de compra
              Consumer<MonedaManager>(
                builder: (context, manager, child) {
                  if (manager.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (manager.error != null) {
                    return Text('Error: ${manager.error}');
                  }

                  // Encontrar la moneda principal solo si no hay una moneda seleccionada
                  if (_monedaSeleccionada == null &&
                      manager.monedas.isNotEmpty) {
                    final monedaPrincipal = manager.monedas.firstWhere(
                      (moneda) => moneda.principal,
                      orElse: () => manager.monedas.first,
                    );
                    _monedaSeleccionada = monedaPrincipal;
                    _tipoCambio = monedaPrincipal.tipoCambio;
                  }

                  // Si tenemos una moneda seleccionada pero no está en la lista actual,
                  // buscar una moneda equivalente por ID
                  if (_monedaSeleccionada != null) {
                    final monedaEquivalente = manager.monedas
                        .where((m) => m.id == _monedaSeleccionada!.id)
                        .firstOrNull;

                    if (monedaEquivalente != null) {
                      _monedaSeleccionada = monedaEquivalente;
                    } else if (manager.monedas.isNotEmpty) {
                      // Si no encontramos la moneda equivalente, usar la principal
                      _monedaSeleccionada = manager.monedas.firstWhere(
                        (moneda) => moneda.principal,
                        orElse: () => manager.monedas.first,
                      );
                      _tipoCambio = _monedaSeleccionada!.tipoCambio;
                    }
                  }

                  return Column(
                    children: [
                      // Selector de moneda
                      DropdownButtonFormField<Moneda>(
                        value: _monedaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        items: manager.monedas.map((moneda) {
                          return DropdownMenuItem<Moneda>(
                            value: moneda,
                            child: Text('${moneda.nombre} (${moneda.codigo})'),
                          );
                        }).toList(),
                        onChanged: _cambioMoneda,
                        validator: (value) {
                          if (value == null) {
                            return 'Seleccione una moneda';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de precio de compra
                      TextFormField(
                        controller: _precioCompraController,
                        decoration: InputDecoration(
                          labelText: 'De Compra',
                          hintText:
                              'Precio en ${_monedaSeleccionada?.nombre ?? 'moneda seleccionada'}',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money_off),
                          suffixText: _monedaSeleccionada?.simbolo ?? '',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el precio de compra';
                          }
                          final precio = double.tryParse(value);
                          if (precio == null || precio <= 0) {
                            return 'Ingrese un precio válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de tipo de cambio (solo lectura)
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Tipo de Cambio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_exchange),
                          suffixText: _monedaSeleccionada?.simbolo ?? '',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _tipoCambio.toString(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Mostrar valor total
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Valor Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_valorTotal.toStringAsFixed(2)} ${_monedaSeleccionada?.simbolo ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _precioPaqueteController,
                decoration: const InputDecoration(
                  labelText: 'Por Rollo',
                  hintText: 'Por metro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  suffixText: 'Bs', // Moneda principal (Boliviano)
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final precio = double.tryParse(value);
                    if (precio == null || precio <= 0) {
                      return 'Ingrese un precio válido';
                    }

                    final compra = double.tryParse(
                      _precioCompraController.text,
                    );
                    if (compra != null && precio <= compra) {
                      return 'Debe ser mayor al precio de compra';
                    }
                  }
                  return null; // Es opcional
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _precioVentaMayorController,
                decoration: const InputDecoration(
                  labelText: 'Por Mayor',
                  hintText: 'Por metro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                  suffixText: 'Bs', // Moneda principal (Boliviano)
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio de venta mayor';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingrese un precio válido';
                  }
                  final rollo = double.tryParse(_precioPaqueteController.text);
                  if (rollo != null && precio <= rollo) {
                    return 'Debe ser mayor al precio por rollo';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _precioVentaMenorController,
                decoration: const InputDecoration(
                  labelText: 'Por Menor',
                  hintText: 'Por metro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_down),
                  suffixText: 'Bs', // Moneda principal (Boliviano)
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio de venta menor';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingrese un precio válido';
                  }
                  final mayor = double.tryParse(
                    _precioVentaMayorController.text,
                  );
                  if (mayor != null && precio <= mayor) {
                    return 'Debe ser mayor al precio por mayor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Lote
              TextFormField(
                controller: _loteController,
                decoration: const InputDecoration(
                  labelText: 'Lote (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),

              const SizedBox(height: 16),

              // Fecha de vencimiento
              TextFormField(
                controller: _fechaVencimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Vencimiento (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectFechaVencimiento,
              ),

              const SizedBox(height: 16),

              // Observaciones
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Selección múltiple de colores
              if (_tipoProductoSeleccionado?.requiereColor ?? false) ...[
                const Text(
                  'Seleccionar colores:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Consumer<ColorManager>(
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

                    return Wrap(
                      spacing: 8,
                      children: manager.colores.map((color) {
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _parseColor(color.codigoColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color.nombreColor),
                            ],
                          ),
                          selected: false,
                          onSelected: (selected) {
                            if (selected) {
                              _agregarColor(color);
                            }
                          },
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Mostrar colores seleccionados con sus cantidades
                if (_coloresSeleccionados.isNotEmpty) ...[
                  const Text(
                    'Colores seleccionados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._coloresSeleccionados.asMap().entries.map((entry) {
                    final index = entry.key;
                    final colorConCantidad = entry.value;

                    return _EntradaColorWidget(
                      entrada: colorConCantidad,
                      unidadMedida:
                          _tipoProductoSeleccionado?.unidadMedida ?? '',
                      cantidadesPosibles: _cantidadesPosibles,
                      onChanged: (nuevaEntrada) {
                        _actualizarEntradaColor(index, nuevaEntrada);
                      },
                      onRemove: () {
                        _eliminarEntradaColor(index);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ],

              // Botón de guardar - ahora navega a la pantalla de detalle
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _guardarStock(_userId),
                  child: const Text('Ver Detalle de Stock'),
                ),
              ),
            ],
          ),
        ),
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

// Widget para cada entrada de color seleccionado
class _EntradaColorWidget extends StatefulWidget {
  final ColorConCantidad entrada;
  final String unidadMedida;
  final List<double> cantidadesPosibles;
  final Function(ColorConCantidad) onChanged;
  final VoidCallback onRemove;

  const _EntradaColorWidget({
    required this.entrada,
    required this.unidadMedida,
    required this.cantidadesPosibles,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  __EntradaColorWidgetState createState() => __EntradaColorWidgetState();
}

class __EntradaColorWidgetState extends State<_EntradaColorWidget> {
  late TextEditingController _cantidadController;
  late TextEditingController _unidadesController;
  late TextEditingController _precioCompraController;
  late TextEditingController _precioVentaMenorController;
  late TextEditingController _precioVentaMayorController;
  late TextEditingController _precioPaqueteController;
  late TextEditingController _loteController;
  late TextEditingController _observacionesController;
  late TextEditingController _fechaVencimientoController;
  bool _expandido = false;
  double _cantidadPrioritaria = 0;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController(
      text: widget.entrada.cantidad.toString(),
    );
    _unidadesController = TextEditingController(
      text: widget.entrada.unidades.toString(),
    );
    _precioCompraController = TextEditingController(
      text: widget.entrada.precioCompra.toString(),
    );
    _precioVentaMenorController = TextEditingController(
      text: widget.entrada.precioVentaMenor.toString(),
    );
    _precioVentaMayorController = TextEditingController(
      text: widget.entrada.precioVentaMayor.toString(),
    );
    _precioPaqueteController = TextEditingController(
      text: widget.entrada.precioPaquete?.toString() ?? '',
    );
    _loteController = TextEditingController(text: widget.entrada.lote ?? '');
    _observacionesController = TextEditingController(
      text: widget.entrada.observaciones ?? '',
    );
    _fechaVencimientoController = TextEditingController(
      text: widget.entrada.fechaVencimiento != null
          ? "${widget.entrada.fechaVencimiento!.day.toString().padLeft(2, '0')}/${widget.entrada.fechaVencimiento!.month.toString().padLeft(2, '0')}/${widget.entrada.fechaVencimiento!.year}"
          : '',
    );

    // Establecer la cantidad prioritaria inicial
    _cantidadPrioritaria = widget.entrada.cantidad;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _unidadesController.dispose();
    _precioCompraController.dispose();
    _precioVentaMenorController.dispose();
    _precioVentaMayorController.dispose();
    _precioPaqueteController.dispose();
    _loteController.dispose();
    _observacionesController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  void _actualizarEntrada() {
    DateTime? fechaVencimiento;
    if (_fechaVencimientoController.text.isNotEmpty) {
      final partes = _fechaVencimientoController.text.split('/');
      if (partes.length == 3) {
        fechaVencimiento = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      }
    }

    final nuevaEntrada = widget.entrada.copyWith(
      cantidad: double.tryParse(_cantidadController.text) ?? 1,
      unidades: int.tryParse(_unidadesController.text) ?? 1,
      precioCompra: double.tryParse(_precioCompraController.text) ?? 0.0,
      precioVentaMenor:
          double.tryParse(_precioVentaMenorController.text) ?? 0.0,
      precioVentaMayor:
          double.tryParse(_precioVentaMayorController.text) ?? 0.0,
      precioPaquete: _precioPaqueteController.text.isNotEmpty
          ? double.tryParse(_precioPaqueteController.text)
          : null,
      lote: _loteController.text.isNotEmpty ? _loteController.text : null,
      fechaVencimiento: fechaVencimiento,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text
          : null,
    );
    widget.onChanged(nuevaEntrada);
  }

  Future<void> _selectFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaVencimientoController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _actualizarEntrada();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Encabezado con color y botón de eliminar
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _parseColor(widget.entrada.color.codigoColor),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(widget.entrada.color.nombreColor),
            subtitle: Text(
              '${widget.entrada.unidades} Unidade(s) contiene ${widget.entrada.cantidad} Metro(s)',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _expandido ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandido = !_expandido;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ),

          // Mostrar información básica incluso cuando no está expandido
          if (!_expandido)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.entrada.lote != null &&
                      widget.entrada.lote!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.tag, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Lote: ${widget.entrada.lote}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  if (widget.entrada.fechaVencimiento != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Vence: ${widget.entrada.fechaVencimiento!.day.toString().padLeft(2, '0')}/${widget.entrada.fechaVencimiento!.month.toString().padLeft(2, '0')}/${widget.entrada.fechaVencimiento!.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  if (widget.entrada.observaciones != null &&
                      widget.entrada.observaciones!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Obs: ${widget.entrada.observaciones}',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Contenido expandible
          if (_expandido)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Campo de cantidad con botones de incremento/decremento
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad por ${widget.unidadMedida}',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Actualizar la cantidad prioritaria cuando cambie el valor
                            final cantidad = double.tryParse(value) ?? 1;
                            setState(() {
                              _cantidadPrioritaria = cantidad;
                            });
                            _actualizarEntrada();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              final cantidad =
                                  int.tryParse(_cantidadController.text) ?? 1;
                              _cantidadController.text = (cantidad + 1)
                                  .toString();
                              setState(() {
                                _cantidadPrioritaria = cantidad + 1;
                              });
                              _actualizarEntrada();
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              final cantidad =
                                  int.tryParse(_cantidadController.text) ?? 1;
                              if (cantidad > 1) {
                                _cantidadController.text = (cantidad - 1)
                                    .toString();
                                setState(() {
                                  _cantidadPrioritaria = cantidad - 1;
                                });
                                _actualizarEntrada();
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cantidades posibles
                  if (widget.cantidadesPosibles.isNotEmpty) ...[
                    const Text(
                      'Cantidades Posibles:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.cantidadesPosibles.map((cantidad) {
                        return InputChip(
                          label: Text('$cantidad'),
                          onPressed: () {
                            setState(() {
                              _cantidadPrioritaria = cantidad;
                              _cantidadController.text = cantidad.toString();
                            });
                            _actualizarEntrada();
                          },
                          selected: _cantidadPrioritaria == cantidad,
                          selectedColor: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo de unidades
                  TextFormField(
                    controller: _unidadesController,
                    decoration: const InputDecoration(
                      labelText: 'Unidades (rollos)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 16),

                  // Campos de precios
                  const Text(
                    'Precios:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _precioCompraController,
                    decoration: const InputDecoration(
                      labelText: 'De Compra',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _precioPaqueteController,
                    decoration: const InputDecoration(
                      labelText: 'Por Rollo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _precioVentaMayorController,
                    decoration: const InputDecoration(
                      labelText: 'Por Mayor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _precioVentaMenorController,
                    decoration: const InputDecoration(
                      labelText: 'Por Menor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 16),

                  // Campo de lote
                  TextFormField(
                    controller: _loteController,
                    decoration: const InputDecoration(
                      labelText: 'Lote',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                  const SizedBox(height: 16),

                  // Campo de fecha de vencimiento
                  TextFormField(
                    controller: _fechaVencimientoController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Vencimiento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectFechaVencimiento,
                  ),
                  const SizedBox(height: 16),

                  // Campo de observaciones
                  TextFormField(
                    controller: _observacionesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (_) => _actualizarEntrada(),
                  ),
                ],
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
