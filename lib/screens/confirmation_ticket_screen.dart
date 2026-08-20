// lib/screens/confirmation_ticket_screen.dart
import 'package:flutter/material.dart';
import 'patient_home_screen.dart';
import 'teleconsultation_screen.dart';

class ConfirmationTicketScreen extends StatelessWidget {
  final dynamic solicitud;
  final String doctorNombre;
  final String especialidad;
  final String servicioNombre;
  final double monto;
  final String fecha;
  final String hora;
  final String metodoPago;

  const ConfirmationTicketScreen({
    super.key,
    this.solicitud,
    this.doctorNombre = 'Dr. Carlos Mendoza',
    this.especialidad = 'Medicina General',
    this.servicioNombre = 'Teleconsulta',
    this.monto = 25.0,
    this.fecha = '20/10/2026',
    this.hora = '10:00 AM',
    this.metodoPago = 'Tarjeta',
  });

  @override
  Widget build(BuildContext context) {
    // Extracción adaptativa de datos si provienen de 'solicitud' o de variables individuales
    final String doc = solicitud != null
        ? (solicitud.profesional ?? doctorNombre)
        : doctorNombre;
    final String serv = solicitud != null
        ? (solicitud.tipo ?? servicioNombre)
        : servicioNombre;
    final String det = solicitud != null
        ? (solicitud.detalle ?? especialidad)
        : especialidad;
    final String fh = solicitud != null
        ? (solicitud.fechaHora ?? '$fecha - $hora')
        : '$fecha - $hora';
    final String codigo = solicitud != null
        ? (solicitud.id ??
              'RES-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}')
        : 'RES-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobante de Reserva'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.teal,
              size: 80,
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Reserva Confirmada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Su solicitud ha sido agendada con éxito.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Detalle del Ticket
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'CÓDIGO: $codigo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    _itemDetalle('Servicio', serv),
                    _itemDetalle('Detalle', det),
                    _itemDetalle('Profesional / Médico', doc),
                    _itemDetalle('Fecha / Hora', fh),
                    _itemDetalle('Método de Pago', metodoPago),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monto Pagado / Estimado',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botones de Acción
            if (serv == 'Teleconsulta')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.video_call),
                  label: const Text('IR A LA SALA DE TELECONSULTA'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeleconsultationScreen(doctorNombre: doc),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('VOLVER AL INICIO'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientHomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDetalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
