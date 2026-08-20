import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://telemedicina-ecuador.onrender.com/api';

  /// Inicia sesión con Cédula/Correo, Contraseña y Rol
  static Future<Map<String, dynamic>> iniciarSesion({
    required String identificador,
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
              'identificador': identificador,
              'password': password,
              'rol': rol,
            }),
          )
          .timeout(const Duration(seconds: 60));

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
          'mensaje': data['mensaje'] ?? 'Credenciales o rol incorrectos.',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión con el servidor. Inténtalo de nuevo.',
      };
    }
  }

  /// Registro de primer ingreso
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
      return {
        'exito': false,
        'mensaje': 'Error de red al conectar con Render.',
      };
    }
  }

  /// Obtener todas las citas desde la API
  static Future<List<dynamic>> obtenerCitas() async {
    try {
      final url = Uri.parse('$baseUrl/citas');
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['citas'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Agendar nueva cita
  static Future<Map<String, dynamic>> agendarCita(
    Map<String, dynamic> datosCita,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/citas');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datosCita),
          )
          .timeout(const Duration(seconds: 40));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Cita agendada exitosamente'};
      } else {
        return {
          'exito': false,
          'mensaje': data['mensaje'] ?? 'Error al agendar cita',
        };
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor.'};
    }
  }

  /// Obtener fichas de triaje registradas
  static Future<List<dynamic>> obtenerAtenciones() async {
    try {
      final url = Uri.parse('$baseUrl/atenciones');
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['atenciones'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Guardar nuevo triaje
  static Future<Map<String, dynamic>> registrarTriaje(
    Map<String, dynamic> datosTriaje,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/atenciones');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datosTriaje),
          )
          .timeout(const Duration(seconds: 40));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Triaje registrado con éxito'};
      } else {
        return {
          'exito': false,
          'mensaje': data['mensaje'] ?? 'Error al guardar triaje',
        };
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor.'};
    }
  }
}
