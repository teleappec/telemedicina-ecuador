import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL de tu servidor desplegado en Render
  static const String baseUrl = 'https://telemedicina-ecuador.onrender.com/api';

  /// Iniciar sesión consultando la API en Render
  static Future<Map<String, dynamic>> iniciarSesion({
    required String cedula,
    required String password,
    required String rol,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'cedula': cedula,
              'password': password,
              'rol': rol,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
          ); // Render puede tardar si estaba dormido

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'usuario': data['usuario'],
          'mensaje': data['mensaje'] ?? 'Acceso autorizado',
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['mensaje'] ?? 'Credenciales incorrectas.',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión con el servidor. Inténtalo de nuevo.',
      };
    }
  }

  /// Ejemplo: Registrar profesional de salud
  static Future<Map<String, dynamic>> registrarProfesional(
    Map<String, dynamic> datos,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/profesionales');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Registro exitoso'};
      } else {
        return {
          'exito': false,
          'mensaje': data['mensaje'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de red al conectar con Render'};
    }
  }
}
