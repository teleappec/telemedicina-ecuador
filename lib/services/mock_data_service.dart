// mock_data_service.dart

class SolicitudAtencion {
  final String id;
  final String tipo; // 'Cita Médica' o 'Enfermería a Domicilio'
  final String detalle; // Especialidad o Servicio contratado
  final String profesional;
  final String fechaHora;
  final String estado; // 'Confirmada', 'En Camino', 'Completada'

  SolicitudAtencion({
    required this.id,
    required this.tipo,
    required this.detalle,
    required this.profesional,
    required this.fechaHora,
    required this.estado,
  });
}

class MockDataService {
  // Lista global en memoria para simular la base de datos
  static final List<SolicitudAtencion> historial = [
    SolicitudAtencion(
      id: 'TK-1001',
      tipo: 'Cita Médica',
      detalle: 'Medicina General (Teleconsulta)',
      profesional: 'Dr. Carlos Mendoza',
      fechaHora: '21/08/2026 • 10:00 AM',
      estado: 'Confirmada',
    ),
    SolicitudAtencion(
      id: 'TK-1002',
      tipo: 'Enfermería a Domicilio',
      detalle: 'Inyectología y Control de Signos',
      profesional: 'Enf. Lic. Fernando Silva',
      fechaHora: '22/08/2026 • 09:00 AM',
      estado: 'En Camino',
    ),
  ];

  static void agregarSolicitud(SolicitudAtencion solicitud) {
    historial.insert(0, solicitud);
  }
}
