// lib/features/empresa/services/reporte_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/venta_model.dart';
import '../models/reporte_filtro_model.dart';
import '../models/stock_tienda_model.dart';
import '../models/stock_empresa_model.dart';

class ReporteService extends BaseService {
  ReporteService() : super('ventas');

  // Obtener ventas del día por usuario
  Future<List<Venta>> getVentasDiaPorUsuario(
    String idUsuario,
    DateTime fecha,
  ) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    final snapshot = await dbRef
        .child('ventas')
        .orderByChild('fechaVenta')
        .startAt(inicio.millisecondsSinceEpoch)
        .endAt(fin.millisecondsSinceEpoch)
        .once();

    List<Venta> ventas = [];
    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final venta = Venta.fromJson(Map<String, dynamic>.from(value), key);
        if (venta.realizadoPor == idUsuario) {
          ventas.add(venta);
        }
      });
    }
    return ventas;
  }

  Future<List<Venta>> getVentasDiaPorTienda(
    String idTienda,
    DateTime fecha,
  ) async {
    print('📅 Buscando ventas para tienda $idTienda en la fecha $fecha');

    // Obtener ventas filtrando por idTienda directamente
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final ventas = <Venta>[];
      final data = snapshot.snapshot.value as Map;

      data.forEach((key, value) {
        // Convertir explícitamente a Map<String, dynamic>
        final Map<String, dynamic> ventaData = Map<String, dynamic>.from(value);
        final venta = Venta.fromJson(ventaData, key);
        if (!venta.deleted) {
          ventas.add(venta);
        }
      });

      // Ordenar por fecha de venta (más reciente primero)
      ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      return ventas;
    }
    return [];
  }

  // Obtener ventas por rango de fechas
  Future<List<Venta>> getVentasPorRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idUsuario,
    String? idTienda,
  }) async {
    final inicio = DateTime(
      fechaInicio.year,
      fechaInicio.month,
      fechaInicio.day,
    );
    final fin = DateTime(
      fechaFin.year,
      fechaFin.month,
      fechaFin.day,
      23,
      59,
      59,
    );

    final snapshot = await dbRef
        .child('ventas')
        .orderByChild('fechaVenta')
        .startAt(inicio.millisecondsSinceEpoch)
        .endAt(fin.millisecondsSinceEpoch)
        .once();

    List<Venta> ventas = [];
    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final venta = Venta.fromJson(Map<String, dynamic>.from(value), key);

        // Filtrar por usuario o tienda si se proporcionan
        if (idUsuario != null && venta.realizadoPor != idUsuario) return;
        if (idTienda != null && venta.idTienda != idTienda) return;

        ventas.add(venta);
      });
    }
    return ventas;
  }

  // Obtener stock actual de la tienda
  Future<List<StockTienda>> getStockActualTienda(String idTienda) async {
    final snapshot = await dbRef
        .child('stock_tienda')
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    List<StockTienda> stocks = [];
    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        stocks.add(StockTienda.fromJson(Map<String, dynamic>.from(value), key));
      });
    }
    return stocks;
  }

  // Obtener stock actual de la empresa
  Future<List<StockEmpresa>> getStockActualEmpresa(String idEmpresa) async {
    final snapshot = await dbRef
        .child('stock_empresa')
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    List<StockEmpresa> stocks = [];
    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        stocks.add(
          StockEmpresa.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
    }
    return stocks;
  }
}
