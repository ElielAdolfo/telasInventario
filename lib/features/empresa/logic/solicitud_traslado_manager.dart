// lib/features/solicitudes/logic/solicitud_traslado_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/movimiento_stock_model.dart';
import 'package:inventario/features/empresa/models/stock_tienda_model.dart';
import 'package:inventario/features/empresa/services/stock_empresa_service.dart';
import 'package:inventario/features/empresa/services/stock_lote_tienda_service.dart';
import 'package:inventario/features/empresa/services/stock_tienda_service.dart';
import '../models/solicitud_traslado_model.dart';
import '../services/solicitud_traslado_service.dart';

class SolicitudTrasladoManager with ChangeNotifier {
  final SolicitudTrasladoService _service = SolicitudTrasladoService();
  final StockEmpresaService _stockService = StockEmpresaService();
  final StockTiendaService _stockTiendaService = StockTiendaService();
  final StockLoteTiendaService _stockLoteTiendaService =
      StockLoteTiendaService();

  List<SolicitudTraslado> _solicitudes = [];
  bool _isLoading = false;
  String? _error;

  List<SolicitudTraslado> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSolicitudesByEmpresa(String idEmpresa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _service.getSolicitudesByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSolicitudesByTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _service.getSolicitudesByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSolicitudesPendientesByTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _service.getSolicitudesPendientesByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NUEVO: Método para generar el correlativo del pedido
  Future<String> _generarCorrelativo(String idEmpresa) async {
    try {
      // Obtener todas las solicitudes de la empresa
      final solicitudes = await _service.getSolicitudesByEmpresa(idEmpresa);

      // Filtrar solo las que tienen correlativo
      final solicitudesConCorrelativo = solicitudes
          .where((s) => s.correlativo != null && s.correlativo!.isNotEmpty)
          .toList();

      if (solicitudesConCorrelativo.isEmpty) {
        // Si no hay solicitudes con correlativo, empezar desde 1
        return 'PED-0001';
      }

      // Ordenar por correlativo (asumiendo formato PED-NNNN)
      solicitudesConCorrelativo.sort((a, b) {
        final numA = int.tryParse(a.correlativo!.substring(4)) ?? 0;
        final numB = int.tryParse(b.correlativo!.substring(4)) ?? 0;
        return numB.compareTo(
          numA,
        ); // Orden descendente para obtener el más reciente
      });

      // Obtener el último correlativo
      final ultimoCorrelativo = solicitudesConCorrelativo.first.correlativo!;
      final numero = int.tryParse(ultimoCorrelativo.substring(4)) ?? 0;
      final nuevoNumero = numero + 1;

      // Formatear el nuevo correlativo con ceros a la izquierda
      return 'PED-${nuevoNumero.toString().padLeft(4, '0')}';
    } catch (e) {
      // Si hay un error, retornar un correlativo por defecto
      return 'PED-0001';
    }
  }

  // MODIFICADO: Crear solicitud con reserva de stock y correlativo
  Future<bool> createSolicitudTraslado(SolicitudTraslado solicitud) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar stock disponible
      final stock = await _stockService.getStockById(solicitud.idStockOrigen);
      if (stock == null) {
        _error = 'No se encontró el stock especificado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar si hay suficiente disponible (considerando reservado y aprobado)
      if (stock.cantidadDisponible < solicitud.cantidadSolicitada) {
        _error =
            'Stock insuficiente. Disponible: ${stock.cantidadDisponible}, Solicitado: ${solicitud.cantidadSolicitada}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Generar el correlativo
      final siguienteCorrelativo = await _service.getSiguienteCorrelativo(
        solicitud.idEmpresa,
      );
      final correlativoFormateado = _service.generarCorrelativo(
        siguienteCorrelativo,
      );

      // Crear la solicitud con estado RESERVADO, correlativo y copia de datos del StockEmpresa
      final solicitudConEstado = solicitud.copyWith(
        estado: 'RESERVADO',
        fechaSolicitud: DateTime.now(),
        correlativo: correlativoFormateado,
        // Campos copiados de StockEmpresa para mantener un registro histórico
        categoria: stock.categoria,
        nombre: stock.nombre,
        unidadMedida: stock.unidadMedida,
        unidadMedidaSecundaria: stock.unidadMedidaSecundaria,
        permiteVentaParcial: stock.permiteVentaParcial,
        requiereColor: stock.requiereColor,
        cantidadesPosibles: stock.cantidadesPosibles,
        cantidadPrioritaria: stock.cantidadPrioritaria,
        precioCompra: stock.precioCompra,
        precioVentaMenor: stock.precioVentaMenor,
        precioVentaMayor: stock.precioVentaMayor,
        lote: stock.lote,
        fechaVencimiento: stock.fechaVencimiento,
        colorNombre:
            solicitud.colorNombre, // Este ya viene de la pantalla de asignación
        colorCodigo:
            solicitud.colorCodigo, // Este ya viene de la pantalla de asignación
        // IDs para referencia
        idTipoProducto: stock.idTipoProducto,
        idColor: stock.idColor,
        // Campos de auditoría
        createdAt: DateTime.now(),
        createdBy: solicitud.solicitadoPor ?? 'sistema',
        updatedAt: DateTime.now(),
        updatedBy: solicitud.solicitadoPor ?? 'sistema',
      );

      final id = await _service.createSolicitudTraslado(solicitudConEstado);
      if (id.isEmpty) {
        _error = 'No se pudo crear la solicitud en la base de datos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Reservar el stock (en lugar de descontarlo directamente)
      final stockActualizado = stock.copyWith(
        cantidadReservado:
            stock.cantidadReservado + solicitud.cantidadSolicitada,
      );
      final resultadoStock = await _stockService.updateStockEmpresa(
        stockActualizado,
      );
      if (!resultadoStock) {
        _error = 'No se pudo actualizar el stock';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Registrar movimiento de reserva
      final movimiento = MovimientoStock(
        id: '',
        idProducto: stock.idTipoProducto,
        idEmpresa: solicitud.idEmpresa,
        idTienda: solicitud.idTienda,
        tipoMovimiento: 'RESERVA',
        cantidad: solicitud.cantidadSolicitada,
        idSolicitudTraslado: id,
        origen: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'EMPRESA'
            : 'TIENDA',
        destino: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'TIENDA'
            : 'EMPRESA',
        fechaMovimiento: DateTime.now(),
        realizadoPor: solicitud.solicitadoPor ?? '',
        // Campos de auditoría
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: solicitud.solicitadoPor ?? 'sistema',
        updatedBy: solicitud.solicitadoPor ?? 'sistema',
      );

      // Aquí debería llamarse al servicio de movimientos para registrar el movimiento
      // await _movimientoService.createMovimientoStock(movimiento);

      await loadSolicitudesByEmpresa(solicitud.idEmpresa);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // NUEVO: Método para obtener una solicitud por su ID
  Future<SolicitudTraslado?> getSolicitudById(String id) async {
    try {
      return await _service.getSolicitudById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<void> updateSolicitudTraslado(SolicitudTraslado solicitud) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateSolicitudTraslado(solicitud);
      await loadSolicitudesByEmpresa(solicitud.idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MODIFICADO: Aprobar solicitud - mover de RESERVADO a APROBADO
  Future<bool> aprobarSolicitud(
    String idSolicitud,
    String idEmpresa,
    String idAprobador,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final solicitud = await _service.getSolicitudById(idSolicitud);
      print("solicitud: " +solicitud.toString());
      if (solicitud == null) {
        _error = 'No se encontró la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar que la solicitud esté en estado RESERVADO
      if (solicitud.estado != 'RESERVADO') {
        _error = 'La solicitud no está en estado RESERVADO';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener el stock
      final stock = await _stockService.getStockById(solicitud.idStockOrigen);
      if (stock == null) {
        _error = 'No se encontró el stock asociado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar la solicitud a APROBADO
      final solicitudActualizada = solicitud.copyWith(
        estado: 'APROBADO',
        aprobadoPor: idAprobador,
        fechaAprobacion: DateTime.now(),
        // Actualizar campos de auditoría
        updatedAt: DateTime.now(),
        updatedBy: idAprobador,
      );

      final resultadoSolicitud = await _service.updateSolicitudTraslado(
        solicitudActualizada,
      );
      if (!resultadoSolicitud) {
        _error = 'No se pudo actualizar la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar stock empresa
      final stockActualizado = stock.copyWith(
        cantidadReservado:
            stock.cantidadReservado - solicitud.cantidadSolicitada,
        cantidadAprobado: stock.cantidadAprobado + solicitud.cantidadSolicitada,
      );

      final resultadoStock = await _stockService.updateStockEmpresa(
        stockActualizado,
      );
      if (!resultadoStock) {
        _error = 'No se pudo actualizar el stock';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear stock en tienda
      var stockTienda = StockTienda(
        id: '', // Se generará en la base de datos
        idTienda: solicitud.idTienda,
        idEmpresa: idEmpresa,
        idTipoProducto: solicitud.idTipoProducto,
        idColor: solicitud.idColor,
        cantidad: solicitud.cantidad,
        unidades: solicitud.cantidadSolicitada,
        cantidadVendida: 0,
        precioCompra: solicitud.precioCompra,
        precioVentaMenor: solicitud.precioVentaMenor,
        precioVentaMayor: solicitud.precioVentaMayor,
        precioPaquete: solicitud.precioPaquete, // Agregar este campo
        fechaIngresoStock: DateTime.now(),
        idSolicitudTraslado: idSolicitud,
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        categoria: solicitud.categoria,
        nombre: solicitud.nombre,
        unidadMedida: solicitud.unidadMedida,
        unidadMedidaSecundaria: solicitud.unidadMedidaSecundaria,
        permiteVentaParcial: solicitud.permiteVentaParcial,
        requiereColor: solicitud.requiereColor,
        lote: solicitud.lote,
        fechaVencimiento: solicitud.fechaVencimiento,
        colorNombre: solicitud.colorNombre,
        colorCodigo: solicitud.colorCodigo,
        idsLotes: [],
        cantidadAperturada: 0,
      );

      final idStockTienda = await _stockTiendaService.createStockTienda(
        stockTienda,
      );
      if (idStockTienda.isEmpty) {
        _error = 'No se pudo crear el stock en tienda';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Registrar movimiento de aprobación
      final movimiento = MovimientoStock(
        id: '',
        idProducto: stock.idTipoProducto,
        idEmpresa: idEmpresa,
        idTienda: solicitud.idTienda,
        tipoMovimiento: 'APROBACION',
        cantidad: solicitud.cantidadSolicitada,
        idSolicitudTraslado: idSolicitud,
        origen: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'EMPRESA'
            : 'TIENDA',
        destino: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'TIENDA'
            : 'EMPRESA',
        fechaMovimiento: DateTime.now(),
        realizadoPor: idAprobador,
        // Campos de auditoría
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: idAprobador,
        updatedBy: idAprobador,
      );

      // Aquí deberías llamar al servicio para guardar el movimiento
      // await _movimientoService.crearMovimiento(movimiento);

      await loadSolicitudesByEmpresa(idEmpresa);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // MODIFICADO: Rechazar solicitud - liberar la reserva
  Future<bool> rechazarSolicitud(
    String idSolicitud,
    String idEmpresa,
    String motivo,
    String idRechazador, // Nuevo parámetro para auditoría
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final solicitud = await _service.getSolicitudById(idSolicitud);
      if (solicitud == null) {
        _error = 'No se encontró la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar que la solicitud esté en estado RESERVADO
      if (solicitud.estado != 'RESERVADO') {
        _error = 'La solicitud no está en estado RESERVADO';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener el stock
      final stock = await _stockService.getStockById(solicitud.idStockOrigen);
      if (stock == null) {
        _error = 'No se encontró el stock asociado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar la solicitud
      final solicitudActualizada = solicitud.copyWith(
        estado: 'RECHAZADO',
        motivoRechazo: motivo,
        fechaRechazo: DateTime.now(),
        // Actualizar campos de auditoría
        updatedAt: DateTime.now(),
        updatedBy: idRechazador,
      );

      final resultadoSolicitud = await _service.updateSolicitudTraslado(
        solicitudActualizada,
      );
      if (!resultadoSolicitud) {
        _error = 'No se pudo actualizar la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Liberar la reserva
      final stockActualizado = stock.copyWith(
        cantidadReservado:
            stock.cantidadReservado - solicitud.cantidadSolicitada,
      );

      final resultadoStock = await _stockService.updateStockEmpresa(
        stockActualizado,
      );
      if (!resultadoStock) {
        _error = 'No se pudo actualizar el stock';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Registrar movimiento de rechazo
      final movimiento = MovimientoStock(
        id: '',
        idProducto: stock.idTipoProducto,
        idEmpresa: idEmpresa,
        idTienda: solicitud.idTienda,
        tipoMovimiento: 'RECHAZO',
        cantidad: solicitud.cantidadSolicitada,
        idSolicitudTraslado: idSolicitud,
        origen: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'EMPRESA'
            : 'TIENDA',
        destino: solicitud.tipoSolicitud == 'EMPRESA_A_TIENDA'
            ? 'TIENDA'
            : 'EMPRESA',
        fechaMovimiento: DateTime.now(),
        realizadoPor: idRechazador,
        observaciones: motivo,
        // Campos de auditoría
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: idRechazador,
        updatedBy: idRechazador,
      );

      // Aquí debería llamarse al servicio de movimientos para registrar el movimiento

      await loadSolicitudesByEmpresa(idEmpresa);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // MODIFICADO: Confirmar recepción - descontar del stock aprobado y total
  Future<bool> confirmarRecepcion(
    String idSolicitud,
    String idTienda,
    String idRecibidoPor,
    int cantidadRecibida,
    String? observaciones,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final solicitud = await _service.getSolicitudById(idSolicitud);
      if (solicitud == null) {
        _error = 'No se encontró la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar que la solicitud esté en estado APROBADO
      if (solicitud.estado != 'APROBADO') {
        _error = 'La solicitud no está en estado APROBADO';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener el stock
      final stock = await _stockService.getStockById(solicitud.idStockOrigen);
      if (stock == null) {
        _error = 'No se encontró el stock asociado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar que la cantidad recibida no supere la aprobada
      if (cantidadRecibida > solicitud.cantidadSolicitada) {
        _error = 'La cantidad recibida no puede superar la cantidad solicitada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar la solicitud
      final solicitudActualizada = solicitud.copyWith(
        estado: 'RECIBIDO',
        recibidoPor: idRecibidoPor,
        fechaRecepcion: DateTime.now(),
        observacionesRecepcion: observaciones,
        // Actualizar campos de auditoría
        updatedAt: DateTime.now(),
        updatedBy: idRecibidoPor,
      );

      final resultadoSolicitud = await _service.updateSolicitudTraslado(
        solicitudActualizada,
      );
      if (!resultadoSolicitud) {
        _error = 'No se pudo actualizar la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Descontar del stock aprobado y del total
      final stockActualizado = stock.copyWith(
        cantidadAprobado: stock.cantidadAprobado - cantidadRecibida,
        cantidad: stock.cantidad - cantidadRecibida,
      );

      final resultadoStock = await _stockService.updateStockEmpresa(
        stockActualizado,
      );
      if (!resultadoStock) {
        _error = 'No se pudo actualizar el stock';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar stock en tienda con la cantidad recibida
      // Aquí debería llamarse al servicio de stock tienda para actualizar el registro

      // Registrar movimiento de recepción
      final movimiento = MovimientoStock(
        id: '',
        idProducto: stock.idTipoProducto,
        idEmpresa: solicitud.idEmpresa,
        idTienda: idTienda,
        tipoMovimiento: 'RECEPCION',
        cantidad: cantidadRecibida,
        idSolicitudTraslado: idSolicitud,
        origen: 'EMPRESA',
        destino: 'TIENDA',
        fechaMovimiento: DateTime.now(),
        realizadoPor: idRecibidoPor,
        observaciones: observaciones,
        // Campos de auditoría
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: idRecibidoPor,
        updatedBy: idRecibidoPor,
      );

      // Aquí debería llamarse al servicio de movimientos para registrar el movimiento

      await loadSolicitudesByTienda(idTienda);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Devolver producto: aumentar el stock total
  Future<bool> devolverProducto(
    String idSolicitud,
    String idTienda,
    String idDevueltoPor,
    int cantidadDevuelta,
    String motivo,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final solicitud = await _service.getSolicitudById(idSolicitud);
      if (solicitud == null) {
        _error = 'No se encontró la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener el stock
      final stock = await _stockService.getStockById(solicitud.idStockOrigen);
      if (stock == null) {
        _error = 'No se encontró el stock asociado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar la solicitud
      final solicitudActualizada = solicitud.copyWith(
        estado: 'DEVUELTO',
        devueltoPor: idDevueltoPor,
        fechaDevolucion: DateTime.now(),
        motivoDevolucion: motivo,
        // Actualizar campos de auditoría
        updatedAt: DateTime.now(),
        updatedBy: idDevueltoPor,
      );

      final resultadoSolicitud = await _service.updateSolicitudTraslado(
        solicitudActualizada,
      );
      if (!resultadoSolicitud) {
        _error = 'No se pudo actualizar la solicitud';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Devolver stock a empresa (aumentar el total)
      final stockActualizado = stock.copyWith(
        cantidad: stock.cantidad + cantidadDevuelta,
      );

      final resultadoStock = await _stockService.updateStockEmpresa(
        stockActualizado,
      );
      if (!resultadoStock) {
        _error = 'No se pudo actualizar el stock';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Registrar movimiento de devolución
      final movimiento = MovimientoStock(
        id: '',
        idProducto: stock.idTipoProducto,
        idEmpresa: solicitud.idEmpresa,
        idTienda: idTienda,
        tipoMovimiento: 'DEVOLUCION',
        cantidad: cantidadDevuelta,
        idSolicitudTraslado: idSolicitud,
        origen: 'TIENDA',
        destino: 'EMPRESA',
        fechaMovimiento: DateTime.now(),
        realizadoPor: idDevueltoPor,
        observaciones: motivo,
        // Campos de auditoría
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: idDevueltoPor,
        updatedBy: idDevueltoPor,
      );

      // Aquí debería llamarse al servicio de movimientos para registrar el movimiento

      await loadSolicitudesByTienda(idTienda);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<SolicitudTraslado>> solicitudesByEmpresaStream(String idEmpresa) {
    return _service.solicitudesByEmpresaStream(idEmpresa);
  }

  Stream<List<SolicitudTraslado>> solicitudesByTiendaStream(String idTienda) {
    return _service.solicitudesByTiendaStream(idTienda);
  }
}
