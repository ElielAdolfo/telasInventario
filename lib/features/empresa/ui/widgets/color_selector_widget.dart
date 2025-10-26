import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/color_model.dart';

class ColorSelectorWithSearch extends StatefulWidget {
  final List<ColorProducto> colores;
  final ColorProducto? selectedColor;
  final Function(ColorProducto) onColorSelected;
  final String? hintText;

  const ColorSelectorWithSearch({
    Key? key,
    required this.colores,
    this.selectedColor,
    required this.onColorSelected,
    this.hintText,
  }) : super(key: key);

  @override
  State<ColorSelectorWithSearch> createState() =>
      _ColorSelectorWithSearchState();
}

class _ColorSelectorWithSearchState extends State<ColorSelectorWithSearch> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  List<ColorProducto> _filteredColors = [];
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    // Ordenar colores alfabéticamente al inicializar
    _filteredColors = List<ColorProducto>.from(widget.colores)
      ..sort((a, b) => a.nombreColor.compareTo(b.nombreColor));

    // Configurar el controlador de búsqueda si hay un color seleccionado
    if (widget.selectedColor != null) {
      _searchController.text = widget.selectedColor!.nombreColor;
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _hideDropdown();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        // Si no hay término de búsqueda, mostrar todos los colores ordenados
        _filteredColors = List<ColorProducto>.from(widget.colores)
          ..sort((a, b) => a.nombreColor.compareTo(b.nombreColor));
      } else {
        // Filtrar colores que coincidan con el término de búsqueda y ordenarlos
        _filteredColors =
            widget.colores
                .where(
                  (color) =>
                      color.nombreColor.toLowerCase().contains(searchTerm),
                )
                .toList()
              ..sort((a, b) => a.nombreColor.compareTo(b.nombreColor));
      }
    });
  }

  // Método para limpiar el campo de búsqueda
  void _clearSearch() {
    _searchController.clear();
    // El listener _onSearchChanged se encargará de actualizar la lista
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _hideDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    setState(() {
      _isDropdownOpen = true;
    });

    // Fix: Use context.findRenderObject() directly without any arguments
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: _buildDropdownContent(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() {
      _isDropdownOpen = false;
    });
  }

  Widget _buildDropdownContent() {
    if (_filteredColors.isEmpty) {
      return const ListTile(
        title: Text('No se encontraron colores'),
        enabled: false,
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: _filteredColors.map((color) {
        return _buildColorOption(color);
      }).toList(),
    );
  }

  Widget _buildColorOption(ColorProducto color) {
    final isSelected = widget.selectedColor?.id == color.id;

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _parseColor(color.codigoColor),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      title: Text(
        color.nombreColor,
        // MODIFICADO: Siempre usar texto negro para el nombre del color
        style: TextStyle(
          color: Colors.black, // Siempre negro
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        widget.onColorSelected(color);
        _searchController.text = color.nombreColor;
        _hideDropdown();
      },
    );
  }

  Widget _buildHorizontalList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Colores disponibles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 95,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredColors.length,
            itemBuilder: (context, index) {
              final color = _filteredColors[index];
              final isSelected = widget.selectedColor?.id == color.id;

              return _buildHorizontalColorItem(color, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalColorItem(ColorProducto color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onColorSelected(color);
        _searchController.text = color.nombreColor;
        _hideDropdown();
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _parseColor(color.codigoColor),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              alignment: Alignment.center,
              child: Text(
                color.nombreColor,
                style: TextStyle(
                  fontSize: 12,
                  // MODIFICADO: Siempre usar texto negro para el nombre del color
                  color: Colors.black, // Siempre negro
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(1.5),
                ),
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

  // Este método ya no es necesario, pero lo dejamos por si se necesita en el futuro
  Color _getTextColorForBackground(String hexColor) {
    final color = _parseColor(hexColor);
    // Calcular la luminancia para determinar si usar texto blanco o negro
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Color:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.selectedColor != null)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _parseColor(widget.selectedColor!.codigoColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (widget.selectedColor != null) const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Buscar color...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      // No mostrar el sufijo para dejar espacio al botón de limpiar
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                // Botón para limpiar la búsqueda (solo visible cuando hay texto)
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: const Icon(Icons.clear, color: Colors.grey),
                  )
                else
                  const Icon(Icons.search, color: Colors.grey),
              ],
            ),
          ),
        ),
        _buildHorizontalList(),
      ],
    );
  }
}
