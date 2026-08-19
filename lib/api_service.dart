import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Solicitar enfermero/a a domicilio
  static Future<Map<String, dynamic>> solicitarEnfermero(
    String direccion,
    String referencia,
    String motivo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enfermeria/solicitar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pacienteCedula': '1799999999',
          'direccion': direccion,
          'referencia': referencia,
          'motivo': motivo,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error al solicitar enfermero: $e');
    }
    return {'exito': false};
  }

  static const String baseUrl = 'http://192.168.100.11:3000/api';
  // Validar datos de médico o enfermero
  static Future<Map<String, dynamic>> validarMedico(
    String cedula,
    String senescyt,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validar-medico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cedula': cedula, 'senescyt': senescyt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'exito': true, 'medico': data['medico']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'exito': false,
          'mensaje': data['mensaje'] ?? 'Error de validación',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor: $e',
      };
    }
  }

  // Obtener catálogo de especialidades y precios desde la DB
  static Future<List<dynamic>> obtenerEspecialidades() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/especialidades'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['especialidades'] ?? [];
      }
    } catch (e) {
      print('Error al cargar especialidades: $e');
    }
    return [];
  }

  // Reservar cita médica y generar comisión
  static Future<Map<String, dynamic>> reservarCita(
    String especialidad,
    double precio,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/citas/reservar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pacienteCedula': '1799999999',
          'especialidad': especialidad,
          'precio': precio,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error al reservar cita: $e');
    }
    return {'exito': false};
  }

  // Sincronizar pacientes offline de triaje
  static Future<Map<String, dynamic>> sincronizarPacientes(
    List<Map<String, dynamic>> pacientes,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sincronizar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pacientes': pacientes}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'exito': true, 'mensaje': data['mensaje']};
      } else {
        return {
          'exito': false,
          'mensaje': 'Error al sincronizar con el servidor',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor: $e',
      };
    }
  }
}
