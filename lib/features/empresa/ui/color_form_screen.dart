// lib/features/color/ui/color_form_screen.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/models/color_model.dart';
import 'package:provider/provider.dart';

class ColorFormScreen extends StatefulWidget {
  final ColorProducto? color;

  const ColorFormScreen({super.key, this.color});

  @override
  State<ColorFormScreen> createState() => _ColorFormScreenState();
}

class _ColorFormScreenState extends State<ColorFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();

  // Color seleccionado
  Color _selectedColor = Colors.blue;

  // Controlador de pestañas
  late TabController _tabController;

  // Imagen para extracción de color
  File? _imageFile;

  // Coordenadas de selección en imagen
  Offset? _selectedPoint;

  // Color extraído de la imagen
  Color? _extractedColor;

  late final String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.color != null) {
      _nombreController.text = widget.color!.nombreColor;
      _codigoController.text = widget.color!.codigoColor;
      _selectedColor = _parseColor(widget.color!.codigoColor);
    }

    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.userId;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _guardarColor() async {
    if (!_formKey.currentState!.validate()) return;

    final manager = Provider.of<ColorManager>(context, listen: false);

    if (widget.color == null) {
      final nuevoColor = ColorProducto(
        id: widget.color?.id ?? '',
        nombreColor: _nombreController.text.trim(),
        codigoColor: _codigoController.text.trim(),
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _userId,
        updatedBy: _userId,
        deletedBy: null,
      );
      await manager.addColor(nuevoColor);
    } else {
      final nuevoColor = ColorProducto(
        id: widget.color?.id ?? '',
        nombreColor: _nombreController.text.trim(),
        codigoColor: _codigoController.text.trim(),
        deleted: widget.color!.deleted,
        deletedAt: widget.color!.deletedAt,
        createdAt: widget.color!.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.color!.createdBy,
        updatedBy: _userId,
        deletedBy: widget.color!.deletedBy,
      );
      await manager.updateColor(nuevoColor);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Convierte un objeto Color a código hexadecimal
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Actualiza el color seleccionado
  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
      _codigoController.text = _colorToHex(color);
    });
  }

  // Toma una foto o selecciona de la galería
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _selectedPoint = null;
        _extractedColor = null;
      });
    }
  }

  // Extrae el color de la imagen en el punto seleccionado
  void _extractColorFromImage(Offset point) {
    if (_imageFile == null) return;

    // Simulación de extracción de color
    // En una implementación real, usarías un paquete como 'image' para procesar la imagen
    setState(() {
      _selectedPoint = point;
      // Simulación de extracción de color
      _extractedColor =
          Colors.primaries[point.dx.toInt() % Colors.primaries.length];
      _selectedColor = _extractedColor!;
      _codigoController.text = _colorToHex(_selectedColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.color == null ? 'Nuevo Color' : 'Editar Color'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _guardarColor)],
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

              // Vista previa del color
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _nombreController.text.isNotEmpty
                            ? _nombreController.text
                            : 'Vista previa',
                        style: TextStyle(
                          color: _getTextColor(_selectedColor),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _colorToHex(_selectedColor),
                        style: TextStyle(
                          color: _getTextColor(_selectedColor),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Selector de método con pestañas
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: [
                        Tab(text: 'Paleta', icon: Icon(Icons.palette)),
                        Tab(text: 'RGB/HSV', icon: Icon(Icons.tune)),
                        Tab(text: 'Imagen', icon: Icon(Icons.image)),
                      ],
                    ),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Pestaña 1: Paleta de colores
                          _buildColorPaletteTab(),

                          // Pestaña 2: Sliders RGB/HSV
                          _buildSliderTab(),

                          // Pestaña 3: Extracción desde imagen
                          _buildImageTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Código hexadecimal (editable)
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código Hexadecimal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                  hintText: '#RRGGBB',
                ),
                onChanged: (value) {
                  final color = _parseColor(value);
                  if (color != Colors.grey) {
                    setState(() {
                      _selectedColor = color;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarColor,
                  child: Text(
                    widget.color == null ? 'Guardar Color' : 'Actualizar Color',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construye la pestaña de paleta de colores
  Widget _buildColorPaletteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Paleta circular HSV
          Container(
            height: 350,
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: _updateColor,
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: BorderRadius.circular(8.0),
            ),
          ),

          SizedBox(height: 16),

          // Paleta de colores predefinidos
          Text(
            'Colores predefinidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...Colors.primaries.map((color) => _buildColorOption(color)),
              ...Colors.accents.map((color) => _buildColorOption(color)),
              _buildColorOption(Colors.white),
              _buildColorOption(Colors.black),
              _buildColorOption(Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  // Construye la pestaña de sliders
  Widget _buildSliderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Selector de modo (RGB/HSV)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text('RGB'),
                selected: true,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              SizedBox(width: 8),
              ChoiceChip(
                label: Text('HSV'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Sliders RGB
          _buildRGBSliders(),

          SizedBox(height: 24),

          // Vista previa del color con valores
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                Text(
                  'Valores RGB',
                  style: TextStyle(
                    color: _getTextColor(_selectedColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'R',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                        Text(
                          '${_selectedColor.red}',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'G',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                        Text(
                          '${_selectedColor.green}',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'B',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                        Text(
                          '${_selectedColor.blue}',
                          style: TextStyle(
                            color: _getTextColor(_selectedColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construye la pestaña de imagen
  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Botones para tomar foto o seleccionar de galería
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Cámara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Galería'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Vista de la imagen con selector de color
          if (_imageFile != null)
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Imagen
                  Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),

                  // Selector de color con lupa
                  Positioned.fill(
                    child: ColorPickerImage(
                      image: _imageFile!,
                      onColorSelected: (color, point) {
                        setState(() {
                          _selectedPoint = point;
                          _extractedColor = color;
                          _selectedColor = color;
                          _codigoController.text = _colorToHex(color);
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Seleccione una imagen',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16),

          // Vista previa del color extraído
          if (_extractedColor != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _extractedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Color seleccionado',
                    style: TextStyle(
                      color: _getTextColor(_extractedColor!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _colorToHex(_extractedColor!),
                    style: TextStyle(
                      color: _getTextColor(_extractedColor!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16),

          // Instrucciones
          Text(
            'Mantén presionado sobre la imagen para activar la lupa y seleccionar el color',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Construye los sliders RGB
  Widget _buildRGBSliders() {
    return Column(
      children: [
        // Slider para el componente Rojo
        Row(
          children: [
            Container(
              width: 30,
              child: Text(
                'R:',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _selectedColor.red.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.red,
                onChanged: (value) {
                  _updateColor(
                    Color.fromARGB(
                      _selectedColor.alpha,
                      value.toInt(),
                      _selectedColor.green,
                      _selectedColor.blue,
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 40,
              child: Text('${_selectedColor.red}', textAlign: TextAlign.right),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Slider para el componente Verde
        Row(
          children: [
            Container(
              width: 30,
              child: Text(
                'G:',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _selectedColor.green.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.green,
                onChanged: (value) {
                  _updateColor(
                    Color.fromARGB(
                      _selectedColor.alpha,
                      _selectedColor.red,
                      value.toInt(),
                      _selectedColor.blue,
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 40,
              child: Text(
                '${_selectedColor.green}',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Slider para el componente Azul
        Row(
          children: [
            Container(
              width: 30,
              child: Text(
                'B:',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _selectedColor.blue.toDouble(),
                min: 0,
                max: 255,
                activeColor: Colors.blue,
                onChanged: (value) {
                  _updateColor(
                    Color.fromARGB(
                      _selectedColor.alpha,
                      _selectedColor.red,
                      _selectedColor.green,
                      value.toInt(),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 40,
              child: Text('${_selectedColor.blue}', textAlign: TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }

  // Construye una opción de color para la paleta
  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => _updateColor(color),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
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

// Widget personalizado para seleccionar color de una imagen con lupa
class ColorPickerImage extends StatefulWidget {
  final File image;
  final Function(Color color, Offset point) onColorSelected;

  const ColorPickerImage({
    super.key,
    required this.image,
    required this.onColorSelected,
  });

  @override
  _ColorPickerImageState createState() => _ColorPickerImageState();
}

class _ColorPickerImageState extends State<ColorPickerImage> {
  bool _showMagnifier = false;
  Offset _position = Offset.zero;
  Color _currentColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        setState(() {
          _showMagnifier = true;
          _position = details.localPosition;
          // Simulación de extracción de color
          _currentColor =
              Colors.primaries[(_position.dx.toInt() + _position.dy.toInt()) %
                  Colors.primaries.length];
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _position = details.localPosition;
          // Simulación de extracción de color
          _currentColor =
              Colors.primaries[(_position.dx.toInt() + _position.dy.toInt()) %
                  Colors.primaries.length];
        });
      },
      onLongPressEnd: (details) {
        setState(() {
          _showMagnifier = false;
          widget.onColorSelected(_currentColor, _position);
        });
      },
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(child: Image.file(widget.image, fit: BoxFit.contain)),

          // Lupa que aparece al mantener presionado
          if (_showMagnifier)
            Positioned(
              left: _position.dx - 50,
              top: _position.dy - 50,
              child: Stack(
                children: [
                  // Círculo de la lupa
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.file(
                        widget.image,
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          (_position.dx / MediaQuery.of(context).size.width) *
                                  2 -
                              1,
                          (_position.dy / MediaQuery.of(context).size.height) *
                                  2 -
                              1,
                        ),
                        scale: 3.0, // Zoom de la lupa
                      ),
                    ),
                  ),

                  // Puntero central
                  Positioned(
                    left: 45,
                    top: 45,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                        color: _currentColor,
                      ),
                    ),
                  ),

                  // Vista previa del color
                  Positioned(
                    bottom: -40,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Center(
                        child: Text(
                          '#${_currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: TextStyle(
                            color: _getTextColor(_currentColor),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Indicador de punto seleccionado
          if (!_showMagnifier && _position != Offset.zero)
            Positioned(
              left: _position.dx - 10,
              top: _position.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: _currentColor,
                ),
              ),
            ),
        ],
      ),
    );
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
