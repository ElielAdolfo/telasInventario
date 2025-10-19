import 'package:flutter/material.dart';
import 'package:inventario/auth_manager.dart';
import 'package:inventario/features/empresa/services/email_service.dart';
import 'package:inventario/features/empresa/ui/role_selection_screen.dart';
import 'package:provider/provider.dart';

// Librerías PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ------------------ PDF ------------------
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PDF de Ejemplo',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Fecha: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}',
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Producto', 'Compra', 'Venta'],
                data: [
                  ['Producto A', '10', '15'],
                  ['Producto B', '20', '25'],
                  ['Producto C', '5', '8'],
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  void _showPdfPreview() async {
    final pdf = await _generatePdf();
    final _recipientController = TextEditingController(
      text: _emailController.text,
    );
    final _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (format) => pdf.save(),
                  allowPrinting: true,
                  allowSharing: true,
                ),
              ),
              // ✅ Inputs debajo del PDF
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Correo destinatario',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              final pdfBytes = await pdf.save();
              Navigator.pop(context);
              _sendEmail(
                to: _recipientController.text,
                body: _messageController.text,
                pdfBytes: pdfBytes,
              );
            },
            child: const Text('Enviar PDF'),
          ),
        ],
      ),
    );
  }

  // ------------------ Enviar correo ------------------
  void _sendEmail({
    required String to,
    String? body,
    List<int>? pdfBytes,
  }) async {
    setState(() => _isLoading = true);

    bool success = await EmailService.sendEmail1(
      to: to,
      subject: pdfBytes != null ? 'PDF desde Flutter' : 'Correo desde Flutter',
      body: body ?? '',
      attachment: pdfBytes != null ? base64Encode(pdfBytes) : null,
      filename: pdfBytes != null ? 'reporte.pdf' : null,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Correo enviado correctamente' : 'Error al enviar correo',
        ),
      ),
    );
  }

  // ------------------ Modal inputs para correo ------------------
  void _showSendEmailModal() {
    final _recipientController = TextEditingController(
      text: _emailController.text,
    );
    final _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enviar PDF por correo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Correo destinatario',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje (opcional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final pdf = await _generatePdf();
              final pdfBytes = await pdf.save();
              _sendEmail(
                to: _recipientController.text,
                body: _messageController.text,
                pdfBytes: pdfBytes,
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  // ------------------ Build ------------------
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    if (auth.isLoggedIn && auth.hasAvailableRoles()) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await auth.signIn(
                              _emailController.text,
                              _passwordController.text,
                            );
                            setState(() => _isLoading = false);
                            if (auth.isLoggedIn && auth.hasAvailableRoles()) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoleSelectionScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Iniciar sesión'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await auth.register(
                              _emailController.text,
                              _passwordController.text,
                            );
                            setState(() => _isLoading = false);
                            if (auth.isLoggedIn && auth.hasAvailableRoles()) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoleSelectionScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text('Registrarse'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showPdfPreview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Vista previa PDF de prueba'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _sendEmail(
                            to: _emailController.text,
                            body:
                                'Este es un correo de prueba enviado desde Flutter.',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Enviar correo de prueba (solo texto)',
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
