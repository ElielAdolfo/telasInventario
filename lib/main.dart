import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventario/auth_gate.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/logic/carrito_manager.dart';
import 'package:inventario/features/empresa/logic/color_manager.dart';
import 'package:inventario/features/empresa/logic/movimiento_stock_manager.dart';
import 'package:inventario/features/empresa/logic/solicitud_traslado_manager.dart';
import 'package:inventario/features/empresa/logic/stock_empresa_manager.dart';
import 'package:inventario/features/empresa/logic/tipo_producto_manager.dart';
import 'package:inventario/features/empresa/logic/unidad_medida_manager.dart';
import 'package:inventario/features/empresa/logic/venta_manager.dart';
import 'package:inventario/features/empresa/logic/venta_producto_manager.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/empresa/ui/empresa_list_screen.dart';
import 'features/empresa/logic/empresa_manager.dart';
import 'features/empresa/logic/tienda_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

/// App principal, carga Firebase y define los providers
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => EmpresaManager()),
        ChangeNotifierProvider(create: (_) => TiendaManager()),
        ChangeNotifierProvider(create: (_) => TipoProductoManager()),
        ChangeNotifierProvider(create: (_) => UnidadMedidaManager()),
        ChangeNotifierProvider(create: (_) => ColorManager()),
        ChangeNotifierProvider(create: (_) => StockEmpresaManager()),
        ChangeNotifierProvider(create: (_) => SolicitudTrasladoManager()),
        ChangeNotifierProvider(create: (_) => MovimientoStockManager()),
        ChangeNotifierProvider(create: (_) => CarritoManager()),
        ChangeNotifierProvider(create: (_) => VentaManager()),
        ChangeNotifierProvider(create: (_) => VentaProductoManager()),
      ],
      child: MaterialApp(
        title: 'Sistema de Gestión de Empresas',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          appBarTheme: const AppBarTheme(centerTitle: true),
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Pantalla de verificación de conexión a Firebase y carga inicial de datos
class FirebaseConnectionScreen extends StatefulWidget {
  const FirebaseConnectionScreen({super.key});

  @override
  State<FirebaseConnectionScreen> createState() =>
      _FirebaseConnectionScreenState();
}

class _FirebaseConnectionScreenState extends State<FirebaseConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 Ahora cargamos las empresas aquí, ya con el Provider montado
    Future.microtask(() {
      context.read<EmpresaManager>().loadEmpresas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<EmpresaManager>(
            builder: (context, manager, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text(
                    'Sistema de Gestión de Empresas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            manager.error == null
                                ? Icons.check_circle
                                : Icons.error,
                            color: manager.error == null
                                ? Colors.green
                                : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Conexión a Firebase',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  manager.error == null
                                      ? 'Conexión establecida correctamente'
                                      : 'Error: ${manager.error}',
                                  style: TextStyle(
                                    color: manager.error == null
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: manager.error == null
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmpresaListScreen(),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Continuar al Sistema'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
