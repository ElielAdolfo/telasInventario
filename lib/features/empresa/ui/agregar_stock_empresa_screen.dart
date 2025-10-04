// lib/features/stock/ui/agregar_stock_empresa_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/logic/stock_empresa_manager.dart';
import 'package:inventario/features/empresa/logic/tipo_producto_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:inventario/features/empresa/models/stock_empresa_model.dart';
import 'package:inventario/features/empresa/models/tipo_producto_model.dart';
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
  final _cantidadController = TextEditingController();
  final _unidadesController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaMenorController = TextEditingController();
  final _precioVentaMayorController = TextEditingController();
  final _precioPaqueteController = TextEditingController(); // Nuevo controlador
  final _loteController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();

  late final String? _userId;

  TipoProducto? _tipoProductoSeleccionado;
  DateTime? _fechaVencimiento;
  ColorProducto? _colorSeleccionado;
  List<int> _cantidadesPosibles = [];
  int _cantidadPrioritaria = 0;

  @override
  void initState() {
    super.initState();
    _tipoProductoSeleccionado = widget.tipoProducto;

    // Si hay un producto preseleccionado, cargar sus datos
    if (_tipoProductoSeleccionado != null) {
      _cargarDatosProducto(_tipoProductoSeleccionado!);
    }

    // Cargar tipos de producto de la empresa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TipoProductoManager>(
        context,
        listen: false,
      ).loadTiposProductoByEmpresa(widget.idEmpresa);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ColorManager>(context, listen: false).loadColores();
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _unidadesController.dispose();
    _precioCompraController.dispose();
    _precioVentaMenorController.dispose();
    _precioVentaMayorController.dispose();
    _precioPaqueteController.dispose(); // Disponer del nuevo controlador
    _loteController.dispose();
    _observacionesController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  // Método para cargar los datos del producto seleccionado
  void _cargarDatosProducto(TipoProducto producto) {
    setState(() {
      _tipoProductoSeleccionado = producto;
      _cantidadesPosibles = List<int>.from(producto.cantidadesPosibles);
      _cantidadPrioritaria = producto.cantidadPrioritaria;

      // Precargar precios por defecto
      _precioCompraController.text = producto.precioCompraDefault.toString();
      _precioVentaMenorController.text = producto.precioVentaDefaultMenor
          .toString();
      _precioVentaMayorController.text = producto.precioVentaDefaultMayor
          .toString();

      // Precargar el precio por paquete si existe
      if (producto.precioPaquete != null) {
        _precioPaqueteController.text = producto.precioPaquete.toString();
      } else {
        _precioPaqueteController.clear();
      }

      // Precargar la cantidad prioritaria en el campo de unidades
      _unidadesController.text = producto.cantidadPrioritaria.toString();
      // Inicializar cantidad en 1 por defecto
      _cantidadController.text = '1';
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

    // Validar color si el producto lo requiere
    if (_tipoProductoSeleccionado!.requiereColor &&
        _colorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un color'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final stockManager = Provider.of<StockEmpresaManager>(
      context,
      listen: false,
    );

    // Obtener el valor del precio por paquete si existe
    double? precioPaquete;
    if (_precioPaqueteController.text.isNotEmpty) {
      precioPaquete = double.tryParse(_precioPaqueteController.text);
    }

    final nuevoStock = StockEmpresa(
      id: '',
      idEmpresa: widget.idEmpresa,
      idTipoProducto: _tipoProductoSeleccionado!.id,
      idColor: _colorSeleccionado?.id,
      cantidad: int.parse(_cantidadController.text),
      unidades: int.parse(_unidadesController.text),
      precioCompra: double.parse(_precioCompraController.text),
      precioVentaMenor: double.parse(_precioVentaMenorController.text),
      precioVentaMayor: double.parse(_precioVentaMayorController.text),
      precioPaquete: precioPaquete, // Nuevo campo
      fechaIngreso: DateTime.now(),
      lote: _loteController.text.isNotEmpty ? _loteController.text : null,
      fechaVencimiento: _fechaVencimiento,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text
          : null,
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Campos adicionales copiados del TipoProducto para mantener una copia independiente
      categoria: _tipoProductoSeleccionado!.categoria,
      nombre: _tipoProductoSeleccionado!.nombre,
      unidadMedida: _tipoProductoSeleccionado!.unidadMedida,
      unidadMedidaSecundaria: _tipoProductoSeleccionado?.unidadMedidaSecundaria,
      permiteVentaParcial: _tipoProductoSeleccionado!.permiteVentaParcial,
      requiereColor: _tipoProductoSeleccionado!.requiereColor,
      // Copiamos las cantidades posibles y la cantidad prioritaria
      cantidadesPosibles: _tipoProductoSeleccionado!.cantidadesPosibles,
      cantidadPrioritaria: _tipoProductoSeleccionado!.cantidadPrioritaria,
      createdBy: userId,
      updatedBy: userId,
      deletedBy: null,
      deletedAt: null,
    );

    try {
      await stockManager.addStockEmpresa(nuevoStock, userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

              // Cantidad por unidad (no enlazado con cantidades posibles)
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: _tipoProductoSeleccionado != null
                      ? 'Cantidad por ${_tipoProductoSeleccionado!.unidadMedida}'
                      : 'Cantidad por unidad',
                  hintText: _tipoProductoSeleccionado != null
                      ? 'Ej: 20 ${_tipoProductoSeleccionado!.unidadMedida.toLowerCase()} por rollo'
                      : 'Ej: 20 metros por rollo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad por unidad';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Mostrar cantidades posibles si hay un producto seleccionado y permite venta parcial
              if (_tipoProductoSeleccionado != null &&
                  _tipoProductoSeleccionado!.permiteVentaParcial) ...[
                const Text(
                  'Cantidades Posibles:',
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
                          _unidadesController.text = cantidad.toString();
                        });
                      },
                      selected: _cantidadPrioritaria == cantidad,
                      selectedColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                /*Text(
                  'Cantidad Prioritaria: $_cantidadPrioritaria',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),*/
              ],

              // Unidades (enlazado con cantidades posibles)
              TextFormField(
                controller: _unidadesController,
                decoration: InputDecoration(
                  labelText:
                      _tipoProductoSeleccionado != null &&
                          _tipoProductoSeleccionado!.permiteVentaParcial
                      ? 'Cantidad por ${_tipoProductoSeleccionado!.unidadMedidaSecundaria}'
                      : 'Unidades',
                  hintText:
                      _tipoProductoSeleccionado != null &&
                          _tipoProductoSeleccionado!.permiteVentaParcial
                      ? 'Ej: 50 ${_tipoProductoSeleccionado!.unidadMedidaSecundaria.toString().toLowerCase()}'
                      : 'Ej: 50 rollos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _tipoProductoSeleccionado != null &&
                            _tipoProductoSeleccionado!.permiteVentaParcial
                        ? 'Ingrese la cantidad por ${_tipoProductoSeleccionado!.unidadMedidaSecundaria}'
                        : 'Ingrese el número de unidades';
                  }
                  final unidades = int.tryParse(value);
                  if (unidades == null || unidades <= 0) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),

              // Mostrar total calculado
              if (_cantidadController.text.isNotEmpty &&
                  _unidadesController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Total: ${int.parse(_cantidadController.text) * int.parse(_unidadesController.text)} ${_tipoProductoSeleccionado?.unidadMedidaSecundaria ?? ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

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
              TextFormField(
                controller: _precioCompraController,
                decoration: const InputDecoration(
                  labelText: 'De Compra',
                  hintText: 'Por metro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money_off),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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

              TextFormField(
                controller: _precioPaqueteController,
                decoration: const InputDecoration(
                  labelText: 'Por Rollo',
                  hintText: 'Por metro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
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

              if (_tipoProductoSeleccionado?.requiereColor ?? false) ...[
                const SizedBox(height: 16),

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

                    return DropdownButtonFormField<ColorProducto>(
                      value: _colorSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette),
                      ),
                      items: manager.colores.map((color) {
                        return DropdownMenuItem<ColorProducto>(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _parseColor(color.codigoColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color.nombreColor),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _colorSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (_tipoProductoSeleccionado?.requiereColor ?? false) {
                          if (value == null) {
                            return 'Seleccione un color';
                          }
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _guardarStock(_userId),
                  child: const Text('Guardar Stock'),
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
