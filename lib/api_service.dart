// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Reemplaza con la URL real de tu instancia en Render
  static const String baseUrl = 'https://telemedicina-ecuador.onrender.com/api';

  /// Guarda un registro de profesional (Médico / Enfermero / Brigada)
  static Future<bool> registrarProfesional(Map<String, dynamic> datos) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/profesionales'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos),
          )
          .timeout(
            const Duration(seconds: 60),
          ); // Manejo del cold start de Render

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al guardar en backend: $e');
      return false;
    }
  }

  /// Agenda una nueva cita médica
  static Future<bool> agendarCita(Map<String, dynamic> citaData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/citas'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(citaData),
          )
          .timeout(const Duration(seconds: 60));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al agendar cita: $e');
      return false;
    }
  }

  /// Obtiene la lista de citas desde la base de datos
  static Future<List<dynamic>> obtenerCitas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/citas'))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error al obtener citas: $e');
      return [];
    }
  }
}
