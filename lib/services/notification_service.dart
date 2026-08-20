// lib/services/notification_service.dart
import 'package:flutter/material.dart';

class NotificationService {
  // Clave global para lanzar notificaciones visuales desde cualquier pantalla
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Muestra un mensaje/alerta emergente estilo banner flotante
  static void mostrarNotificacion({
    required String titulo,
    required String mensaje,
    IconData icono = Icons.notifications_active,
    Color colorFondo = Colors.teal,
  }) {
    messengerKey.currentState?.clearSnackBars();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorFondo,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icono, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mensaje,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Programa un recordatorio diferido de la cita médica
  static void programarRecordatorioCita({
    required String doctorNombre,
    required String fechaHora,
    int segundosDeRetraso = 5,
  }) {
    Future.delayed(Duration(seconds: segundosDeRetraso), () {
      mostrarNotificacion(
        titulo: 'Recordatorio de Cita Médica ⏰',
        mensaje: 'Su consulta con $doctorNombre está programada ($fechaHora).',
        icono: Icons.alarm,
        colorFondo: Colors.indigo.shade700,
      );
    });
  }
}
