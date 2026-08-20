// patient_home_screen.dart
import 'package:flutter/material.dart';
import 'appointment_screen.dart';
import 'request_nurse_screen.dart';
import 'medical_history_screen.dart';
import 'role_selection_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFF00796B)),
              SizedBox(width: 10),
              Text(
                'Cambiar de Perfil',
                style: TextStyle(fontSize: 18, color: Color(0xFF004D40)),
              ),
            ],
          ),
          content: const Text(
            '¿Deseas salir del menú de paciente y volver a la selección de perfil?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorIcono,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade100, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorIcono.withOpacity(0.12),
                child: Icon(icono, color: colorIcono, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF00796B),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú del Paciente'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Cambiar Perfil / Salir',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¿Qué servicio necesitas el día de hoy?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // 1. Agendar Cita
            _buildMenuCard(
              context: context,
              titulo: 'Agendar Cita Médica',
              subtitulo:
                  'Reserva una cita presencial o virtual con nuestros especialistas.',
              icono: Icons.calendar_month_rounded,
              colorIcono: const Color(0xFF00796B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Enfermería a Domicilio
            _buildMenuCard(
              context: context,
              titulo: 'Enfermería a Domicilio',
              subtitulo:
                  'Solicita inyectología, curaciones, control de signos vitales o cuidados a casa.',
              icono: Icons.vaccines_rounded,
              colorIcono: const Color(0xFF0288D1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestNurseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Historial Clínico y Recetas
            _buildMenuCard(
              context: context,
              titulo: 'Historial Clínico y Mis Recetas',
              subtitulo:
                  'Revisa diagnósticos anteriores y descarga tus recetas médicas en PDF.',
              icono: Icons.receipt_long_rounded,
              colorIcono: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicalHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
