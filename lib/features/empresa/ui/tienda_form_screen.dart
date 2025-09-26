import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/tienda_manager.dart';
import 'package:provider/provider.dart';
import '../models/tienda_model.dart';

class TiendaFormScreen extends StatefulWidget {
  final String empresaId;
  final Tienda? tienda;

  const TiendaFormScreen({Key? key, required this.empresaId, this.tienda})
    : super(key: key);

  @override
  _TiendaFormScreenState createState() => _TiendaFormScreenState();
}

class _TiendaFormScreenState extends State<TiendaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _encargadoController;
  bool _isWarehouse = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.tienda?.nombre ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.tienda?.direccion ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.tienda?.telefono ?? '',
    );
    _encargadoController = TextEditingController(
      text: widget.tienda?.encargado ?? '',
    );
    _isWarehouse = widget.tienda?.isWarehouse ?? false;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _encargadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tienda == null ? 'Nueva Tienda' : 'Editar Tienda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _encargadoController,
                decoration: const InputDecoration(
                  labelText: 'Encargado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del encargado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Es almacén'),
                subtitle: const Text(
                  'Si es almacén, no se pueden vender rollos directamente',
                ),
                value: _isWarehouse,
                onChanged: (value) {
                  setState(() {
                    _isWarehouse = value;
                  });
                },
                secondary: Icon(
                  _isWarehouse ? Icons.warehouse : Icons.store,
                  color: _isWarehouse ? Colors.brown : Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.tienda == null
                            ? 'Crear Tienda'
                            : 'Actualizar Tienda',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tienda = widget.tienda == null
          ? Tienda(
              id: '',
              empresaId: widget.empresaId,
              nombre: _nombreController.text,
              direccion: _direccionController.text,
              telefono: _telefonoController.text,
              encargado: _encargadoController.text,
              isWarehouse: _isWarehouse,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : widget.tienda!.copyWith(
              nombre: _nombreController.text,
              direccion: _direccionController.text,
              telefono: _telefonoController.text,
              encargado: _encargadoController.text,
              isWarehouse: _isWarehouse,
            );

      final manager = Provider.of<TiendaManager>(context, listen: false);

      try {
        if (widget.tienda == null) {
          await manager.addTienda(tienda);
        } else {
          await manager.updateTienda(tienda);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
