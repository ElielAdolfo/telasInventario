// lib/features/moneda/ui/moneda_form_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/moneda_manager.dart';
import 'package:inventario/features/empresa/models/moneda_model.dart';
import 'package:provider/provider.dart';

class MonedaFormScreen extends StatefulWidget {
  final Moneda? moneda;

  const MonedaFormScreen({super.key, this.moneda});

  @override
  State<MonedaFormScreen> createState() => _MonedaFormScreenState();
}

class _MonedaFormScreenState extends State<MonedaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _simboloController = TextEditingController();
  final _tipoCambioController = TextEditingController();
  bool _principal = false;

  @override
  void initState() {
    super.initState();
    if (widget.moneda != null) {
      _nombreController.text = widget.moneda!.nombre;
      _codigoController.text = widget.moneda!.codigo;
      _simboloController.text = widget.moneda!.simbolo;
      _tipoCambioController.text = widget.moneda!.tipoCambio.toString();
      _principal = widget.moneda!.principal;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _simboloController.dispose();
    _tipoCambioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moneda == null ? 'Agregar Moneda' : 'Editar Moneda'),
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
                  labelText: 'Nombre de la moneda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código (ej: USD, EUR, PEN)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el código';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _simboloController,
                decoration: InputDecoration(
                  labelText: 'Símbolo (ej: \$, €, S/)',
                  border: const OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el símbolo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Moneda principal'),
                value: _principal,
                onChanged: (value) {
                  setState(() {
                    _principal = value;
                  });
                },
              ),
              if (!_principal)
                TextFormField(
                  controller: _tipoCambioController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cambio',
                    border: OutlineInputBorder(),
                    hintText: '1.0',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el tipo de cambio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMoneda,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMoneda() async {
    if (_formKey.currentState!.validate()) {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      final String? userId = authManager.userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo identificar al usuario'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final moneda = Moneda(
        id: widget.moneda?.id ?? '',
        nombre: _nombreController.text,
        codigo: _codigoController.text,
        simbolo: _simboloController.text,
        principal: _principal,
        tipoCambio: _principal
            ? 1.0
            : double.tryParse(_tipoCambioController.text) ?? 1.0,
        createdAt: widget.moneda?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final manager = Provider.of<MonedaManager>(context, listen: false);

      try {
        if (widget.moneda == null) {
          await manager.addMoneda(moneda, userId);
        } else {
          await manager.updateMoneda(moneda, userId);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
