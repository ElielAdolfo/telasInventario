// lib/features/producto/ui/unidad_medida_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unidad_medida_model.dart';
import '../logic/unidad_medida_manager.dart';

class UnidadMedidaFormScreen extends StatefulWidget {
  final UnidadMedida? unidad;

  const UnidadMedidaFormScreen({Key? key, this.unidad}) : super(key: key);

  @override
  _UnidadMedidaFormScreenState createState() => _UnidadMedidaFormScreenState();
}

class _UnidadMedidaFormScreenState extends State<UnidadMedidaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.unidad?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.unidad?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.unidad == null
              ? 'Nueva Unidad de Medida'
              : 'Editar Unidad de Medida',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: METRO, KILOGRAMO, UNIDAD',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre de la unidad de medida';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Formatear automáticamente a mayúsculas y sin espacios
                  final formattedValue = UnidadMedida.formatearNombre(value);
                  if (formattedValue != value) {
                    _nombreController.value = _nombreController.value.copyWith(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                        offset: formattedValue.length,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  hintText: 'Descripción de la unidad de medida',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la descripción';
                  }
                  return null;
                },
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
                        widget.unidad == null ? 'Crear' : 'Actualizar',
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

      final unidad = widget.unidad == null
          ? UnidadMedida(
              id: '',
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : widget.unidad!.copyWith(
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
            );

      final manager = Provider.of<UnidadMedidaManager>(context, listen: false);

      try {
        // Verificar si ya existe una unidad con el mismo nombre
        if (widget.unidad == null) {
          final exists = await manager.existsUnidadMedidaByNombre(
            unidad.nombre,
          );
          if (exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ya existe una unidad de medida con este nombre'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        if (widget.unidad == null) {
          await manager.addUnidadMedida(unidad);
        } else {
          await manager.updateUnidadMedida(unidad);
        }

        Navigator.pop(context);
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
