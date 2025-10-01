// lib/features/color/ui/color_form_screen.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:provider/provider.dart';

class ColorFormScreen extends StatefulWidget {
  final ColorProducto? color;

  const ColorFormScreen({super.key, this.color});

  @override
  State<ColorFormScreen> createState() => _ColorFormScreenState();
}

class _ColorFormScreenState extends State<ColorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();

  // Color seleccionado para el picker
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.color != null) {
      _nombreController.text = widget.color!.nombreColor;
      _codigoController.text = widget.color!.codigoColor;
      // Inicializar el color seleccionado desde el código hexadecimal
      _selectedColor = _parseColor(widget.color!.codigoColor);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  void _guardarColor() async {
    if (!_formKey.currentState!.validate()) return;

    final manager = Provider.of<ColorManager>(context, listen: false);

    final nuevoColor = ColorProducto(
      id: widget.color?.id ?? '',
      nombreColor: _nombreController.text.trim(),
      codigoColor: _codigoController.text.trim(),
      createdAt: widget.color?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.color == null) {
      await manager.addColor(nuevoColor);
    } else {
      await manager.updateColor(nuevoColor);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Muestra el diálogo para seleccionar un color
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                  // Actualizar el código hexadecimal cuando cambia el color
                  _codigoController.text = _colorToHex(color);
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Convierte un objeto Color a código hexadecimal
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.color == null ? 'Nuevo Color' : 'Editar Color'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del color
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Color',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre del color';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Selector de color visual
              InkWell(
                onTap: _showColorPicker,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.colorize,
                        color: _getTextColor(_selectedColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seleccionar color',
                        style: TextStyle(
                          color: _getTextColor(_selectedColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Código hexadecimal (solo lectura)
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código Hexadecimal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                  suffixIcon: Icon(Icons.lock), // Indica que es solo lectura
                ),
                readOnly: true, // Hacer el campo solo lectura
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Vista previa del color
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    _nombreController.text.isNotEmpty
                        ? _nombreController.text
                        : 'Vista previa',
                    style: TextStyle(
                      color: _getTextColor(_selectedColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarColor,
                  child: Text(widget.color == null ? 'Guardar' : 'Actualizar'),
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

  Color _getTextColor(Color backgroundColor) {
    // Calcular el brillo del color para decidir si usar texto blanco o negro
    double brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }
}

// Widget personalizado para seleccionar colores
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Paleta de colores predefinidos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorOption(Colors.red),
            _buildColorOption(Colors.pink),
            _buildColorOption(Colors.purple),
            _buildColorOption(Colors.deepPurple),
            _buildColorOption(Colors.indigo),
            _buildColorOption(Colors.blue),
            _buildColorOption(Colors.lightBlue),
            _buildColorOption(Colors.cyan),
            _buildColorOption(Colors.teal),
            _buildColorOption(Colors.green),
            _buildColorOption(Colors.lightGreen),
            _buildColorOption(Colors.lime),
            _buildColorOption(Colors.yellow),
            _buildColorOption(Colors.amber),
            _buildColorOption(Colors.orange),
            _buildColorOption(Colors.deepOrange),
            _buildColorOption(Colors.brown),
            _buildColorOption(Colors.grey),
            _buildColorOption(Colors.blueGrey),
            _buildColorOption(Colors.black),
            _buildColorOption(Colors.white),
          ],
        ),

        const SizedBox(height: 16),

        // Selector de color personalizado (deslizador RGB)
        Text('Personalizar:', style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),

        // Slider para el componente Rojo
        Row(
          children: [
            Text('R:'),
            Expanded(
              child: Slider(
                value: _selectedColor.red.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = Color.fromARGB(
                      _selectedColor.alpha,
                      value.toInt(),
                      _selectedColor.green,
                      _selectedColor.blue,
                    );
                    widget.onColorChanged(_selectedColor);
                  });
                },
              ),
            ),
            Text('${_selectedColor.red}'),
          ],
        ),

        // Slider para el componente Verde
        Row(
          children: [
            Text('G:'),
            Expanded(
              child: Slider(
                value: _selectedColor.green.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = Color.fromARGB(
                      _selectedColor.alpha,
                      _selectedColor.red,
                      value.toInt(),
                      _selectedColor.blue,
                    );
                    widget.onColorChanged(_selectedColor);
                  });
                },
              ),
            ),
            Text('${_selectedColor.green}'),
          ],
        ),

        // Slider para el componente Azul
        Row(
          children: [
            Text('B:'),
            Expanded(
              child: Slider(
                value: _selectedColor.blue.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = Color.fromARGB(
                      _selectedColor.alpha,
                      _selectedColor.red,
                      _selectedColor.green,
                      value.toInt(),
                    );
                    widget.onColorChanged(_selectedColor);
                  });
                },
              ),
            ),
            Text('${_selectedColor.blue}'),
          ],
        ),

        const SizedBox(height: 16),

        // Vista previa del color seleccionado
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              _colorToHex(_selectedColor),
              style: TextStyle(
                color: _getTextColor(_selectedColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          widget.onColorChanged(color);
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedColor == color ? Colors.black : Colors.grey,
            width: _selectedColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _getTextColor(Color backgroundColor) {
    double brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }
}
