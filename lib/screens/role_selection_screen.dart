import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'patient_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _mostrarDialogoRegistro(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final cedulaController = TextEditingController();
    final senescytController = TextEditingController();
    final especialidadController = TextEditingController();
    bool cargando = false;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF00796B),
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Registro de Personal Médico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete el formulario para solicitar su alta en el sistema nacional.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre y Apellido Completo',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF00796B),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese su nombre completo'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: cedulaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cédula de Identidad',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF00796B),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese la cédula de identidad'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: senescytController,
                          decoration: InputDecoration(
                            labelText: 'Nº Registro SENESCYT',
                            hintText: 'Ej: 1005-2022-8844',
                            prefixIcon: const Icon(
                              Icons.verified_outlined,
                              color: Color(0xFF00796B),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese el código SENESCYT'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: especialidadController,
                          decoration: InputDecoration(
                            labelText: 'Especialidad / Cargo',
                            hintText:
                                'Ej: Medicina General, Enfermería, Brigada',
                            prefixIcon: const Icon(
                              Icons.medical_services_outlined,
                              color: Color(0xFF00796B),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingrese su especialidad'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: cargando ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: cargando
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateModal(() => cargando = true);

                            // Simulación de procesamiento de registro
                            await Future.delayed(
                              const Duration(milliseconds: 1200),
                            );

                            setStateModal(() => cargando = false);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '¡Registro creado con éxito para Dr/a. ${nombreController.text}! Ya puede ingresar.',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF00796B),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                  child: cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'REGISTRAR MÉDICO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPerfilCard({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorIcono,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade100, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorIcono.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 32, color: colorIcono),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 13,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFFF4FBFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.85],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Escudo Principal
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 60,
                        color: Color(0xFF00796B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'TeleMedicina Ecuador',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona tu perfil para ingresar a la plataforma',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.teal.shade50,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tarjeta: Soy Paciente
                    _buildPerfilCard(
                      context: context,
                      titulo: 'Soy Paciente',
                      subtitulo:
                          'Solicitar cita médica, teleconsulta o enfermería a domicilio.',
                      icono: Icons.person_rounded,
                      colorIcono: const Color(0xFF0288D1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PatientHomeScreen(), // 👈 Dirige al menú principal del paciente
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tarjeta: Personal de Salud
                    _buildPerfilCard(
                      context: context,
                      titulo: 'Médico / Enfermero / Brigada',
                      subtitulo:
                          'Acceso profesional con cédula y registro SENESCYT.',
                      icono: Icons.medical_services_rounded,
                      colorIcono: const Color(0xFF00796B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Botón para Nuevo Personal de Salud
                    OutlinedButton.icon(
                      onPressed: () => _mostrarDialogoRegistro(context),
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Color(0xFF004D40),
                      ),
                      label: const Text(
                        '¿Eres nuevo profesional? Regístrate aquí',
                        style: TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF00796B),
                          width: 1.5,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pie Institucional
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Red Nacional de Telemedicina • MSP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
