// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'doctor_profile_screen.dart';
import 'patient_flow_screen.dart';
import 'triage_screen.dart';

enum RolProfesional { medico, enfermero, brigada }

class LoginScreen extends StatefulWidget {
  final RolProfesional rolInicial;

  const LoginScreen({super.key, this.rolInicial = RolProfesional.medico});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _senescytController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  late RolProfesional _rolSeleccionado;

  @override
  void initState() {
    super.initState();
    _rolSeleccionado = widget.rolInicial;
  }

  /// Validador de Cédula Ecuatoriana (10 dígitos)
  String? _validarCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su número de cédula';
    }
    final cedula = value.trim();
    if (cedula.length != 10 || int.tryParse(cedula) == null) {
      return 'La cédula debe contener 10 dígitos numéricos';
    }
    return null;
  }

  /// Validador del Registro SENESCYT / Código Institucional
  String? _validarSenescyt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su registro SENESCYT o código de brigada';
    }
    return null;
  }

  /// Validador de Contraseña
  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String get _nombreRol {
    switch (_rolSeleccionado) {
      case RolProfesional.medico:
        return 'MÉDICO';
      case RolProfesional.enfermero:
        return 'ENFERMERO';
      case RolProfesional.brigada:
        return 'BRIGADA';
    }
  }

  Color get _colorRol {
    switch (_rolSeleccionado) {
      case RolProfesional.medico:
        return Colors.teal.shade800;
      case RolProfesional.enfermero:
        return Colors.indigo.shade800;
      case RolProfesional.brigada:
        return Colors.deepOrange.shade800;
    }
  }

  void _procesarIngreso() {
    if (_formKey.currentState!.validate()) {
      NotificationService.mostrarNotificacion(
        titulo: 'Bienvenido(a) 🎉',
        mensaje: 'Acceso autorizado como $_nombreRol.',
        icono: Icons.verified_user,
        colorFondo: _colorRol,
      );

      // Redirección según el rol profesional seleccionado
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
        titulo: 'Formulario Incompleto ⚠️',
        mensaje: 'Verifique los datos ingresados.',
        icono: Icons.warning_amber_rounded,
        colorFondo: Colors.orange.shade900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso de Personal de Salud'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portal Profesional MSP',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Seleccione su perfil operativo para ingresar:',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Pestañas / Selector de Perfil Profesional
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        'Médico',
                        RolProfesional.medico,
                        Icons.medical_services,
                      ),
                      _buildTabButton(
                        'Enfermero',
                        RolProfesional.enfermero,
                        Icons.local_hospital,
                      ),
                      _buildTabButton(
                        'Brigada',
                        RolProfesional.brigada,
                        Icons.biotech,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Campo Cédula
                TextFormField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Cédula de Identidad',
                    hintText: 'Ej. 1723456789',
                    prefixIcon: Icon(Icons.badge, color: Colors.teal),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarCedula,
                ),
                const SizedBox(height: 14),

                // Campo Registro SENESCYT
                TextFormField(
                  controller: _senescytController,
                  decoration: InputDecoration(
                    labelText: _rolSeleccionado == RolProfesional.brigada
                        ? 'Código de Brigada / MSP'
                        : 'Registro SENESCYT',
                    hintText: 'Ej. 1005-2023-123456',
                    prefixIcon: const Icon(Icons.verified, color: Colors.teal),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validarSenescyt,
                ),
                const SizedBox(height: 14),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validarPassword,
                ),
                const SizedBox(height: 28),

                // Botón de Envío
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorRol,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _procesarIngreso,
                    child: Text(
                      'INGRESAR COMO $_nombreRol',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String texto, RolProfesional rol, IconData icono) {
    final bool seleccionado = _rolSeleccionado == rol;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _rolSeleccionado = rol;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: seleccionado ? _colorRol : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 20,
                color: seleccionado ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(height: 4),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
