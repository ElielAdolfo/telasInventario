import 'dart:convert';
import 'package:http/http.dart' as http;
import '/../environment.dart';

class EmailService {
  /// Envía un correo. Si [pdfBytes] no es nulo, se envía como base64 adjunto.
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<int>? pdfBytes, // <--- agregado
  }) async {
    final Map<String, dynamic> data = {
      'to': to,
      'subject': subject,
      'body': body,
    };

    if (pdfBytes != null) {
      data['pdf'] = base64Encode(pdfBytes); // Enviamos PDF codificado en base64
    }

    final response = await http.post(
      Uri.parse(Environment.apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Environment.bearerToken}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al enviar correo: ${response.body}');
      return false;
    }
  }

  static Future<bool> sendEmail1({
    required String to,
    required String subject,
    required String body,
    String? attachment,
    String? filename,
  }) async {
    final response = await http.post(
      Uri.parse(Environment.apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Environment.bearerToken}',
      },
      body: jsonEncode({
        'to': to,
        'subject': subject,
        'body': body,
        'attachment': attachment,
        'filename': filename,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al enviar correo: ${response.body}');
      return false;
    }
  }
}
