import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'doctor_profile_screen.dart';
import 'triage_screen.dart';
import 'patient_flow_screen.dart';

enum RolProfesional { medico, enfermero, brigada }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RolProfesional _rolSeleccionado = RolProfesional.medico;
  bool _cargando = false;
  bool _ocultarPassword = true;

  String get _nombreRol {
    switch (_rolSeleccionado) {
      case RolProfesional.medico:
        return 'Médico';
      case RolProfesional.enfermero:
        return 'Enfermero';
      case RolProfesional.brigada:
        return 'Brigada';
    }
  }

  Color get _colorRol {
    switch (_rolSeleccionado) {
      case RolProfesional.medico:
        return const Color(0xFF1E88E5);
      case RolProfesional.enfermero:
        return const Color(0xFF26A69A);
      case RolProfesional.brigada:
        return const Color(0xFF8E24AA);
    }
  }

  Future<void> _procesarIngreso() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    // Consulta real al Backend en Render
    final resultado = await ApiService.iniciarSesion(
      cedula: _cedulaController.text.trim(),
      password: _passwordController.text,
      rol: _nombreRol,
    );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (resultado['exito'] == true) {
      NotificationService.mostrarNotificacion(
        titulo: 'Acceso Concedido 🎉',
        mensaje: 'Bienvenido(a) $_nombreRol.',
        icono: Icons.verified_user,
        colorFondo: _colorRol,
      );

      Widget pantallaDestino;
      switch (_rolSeleccionado) {
        case RolProfesional.medico:
          pantallaDestino = const DoctorProfileScreen();
          break;
        case RolProfesional.enfermero:
          pantallaDestino = const TriageScreen();
          break;
        case RolProfesional.brigada:
          pantallaDestino = const PatientFlowScreen();
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => pantallaDestino),
      );
    } else {
      NotificationService.mostrarNotificacion(
        titulo: 'Acceso Denegado ❌',
        mensaje: resultado['mensaje'] ?? 'Cédula o contraseña incorrectas.',
        icono: Icons.error_outline,
        colorFondo: Colors.red.shade800,
      );
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_hospital, size: 64, color: _colorRol),
                    const SizedBox(height: 16),
                    const Text(
                      'Telemedicina Ecuador',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selector de Rol
                    DropdownButtonFormField<RolProfesional>(
                      value: _rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Rol Profesional',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RolProfesional.medico,
                          child: Text('Médico'),
                        ),
                        DropdownMenuItem(
                          value: RolProfesional.enfermero,
                          child: Text('Enfermero'),
                        ),
                        DropdownMenuItem(
                          value: RolProfesional.brigada,
                          child: Text('Brigada'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _rolSeleccionado = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Cédula
                    TextFormField(
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de Cédula',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingrese su número de cédula';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _ocultarPassword = !_ocultarPassword,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón de Ingreso
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorRol,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _cargando ? null : _procesarIngreso,
                        child: _cargando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'INGRESAR AL SISTEMA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
