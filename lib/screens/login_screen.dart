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

  bool _esModoRegistro = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _senescytController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

  Future<void> _procesarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    if (_esModoRegistro) {
      // REGISTRO PRIMERA VEZ
      final resultado = await ApiService.registrarProfesional({
        'nombre': _nombreController.text.trim(),
        'correo': _correoController.text.trim().toLowerCase(),
        'cedula': _cedulaController.text.trim(),
        'senescyt': _senescytController.text.trim(),
        'password': _passwordController.text,
        'rol': _nombreRol,
      });

      if (!mounted) return;
      setState(() => _cargando = false);

      if (resultado['exito'] == true) {
        NotificationService.mostrarNotificacion(
          titulo: '¡Registro Exitoso! 🎉',
          mensaje:
              'Cuenta creada para $_nombreRol. Inicia sesión para continuar.',
          icono: Icons.check_circle_outline,
          colorFondo: _colorRol,
        );

        setState(() {
          _esModoRegistro = false;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        NotificationService.mostrarNotificacion(
          titulo: 'Error en Registro ❌',
          mensaje: resultado['mensaje'] ?? 'No se pudo crear la cuenta.',
          icono: Icons.error_outline,
          colorFondo: Colors.red.shade800,
        );
      }
    } else {
      // INICIO DE SESIÓN
      final resultado = await ApiService.iniciarSesion(
        identificador: _cedulaController.text.trim(),
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
          mensaje:
              resultado['mensaje'] ?? 'Cédula/Correo o contraseña incorrectos.',
          icono: Icons.error_outline,
          colorFondo: Colors.red.shade800,
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _cedulaController.dispose();
    _senescytController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    Icon(
                      _esModoRegistro
                          ? Icons.person_add_alt_1
                          : Icons.local_hospital,
                      size: 60,
                      color: _colorRol,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _esModoRegistro
                          ? 'Registro de Nuevo Profesional'
                          : 'Telemedicina Ecuador',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

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
                        if (val != null) setState(() => _rolSeleccionado = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nombre y Apellido (Solo Registro)
                    if (_esModoRegistro) ...[
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre y Apellido',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) {
                          if (_esModoRegistro &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Ingrese su nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Correo Electrónico
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'ejemplo@correo.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (val) {
                          if (_esModoRegistro) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Ingrese su correo electrónico';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Ingrese un correo válido';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Cédula o Correo (Login) / Cédula (Registro)
                    TextFormField(
                      controller: _cedulaController,
                      decoration: InputDecoration(
                        labelText: _esModoRegistro
                            ? 'Número de Cédula'
                            : 'Cédula o Correo Electrónico',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          _esModoRegistro
                              ? Icons.badge_outlined
                              : Icons.account_circle,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return _esModoRegistro
                              ? 'Ingrese su número de cédula'
                              : 'Ingrese su cédula o correo';
                        }
                        if (_esModoRegistro && val.trim().length != 10) {
                          return 'La cédula debe tener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // SENESCYT (Solo Registro)
                    if (_esModoRegistro) ...[
                      TextFormField(
                        controller: _senescytController,
                        decoration: const InputDecoration(
                          labelText: 'Registro SENESCYT / Código MSP',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.verified),
                        ),
                        validator: (val) {
                          if (_esModoRegistro &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Ingrese su código SENESCYT o MSP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      decoration: InputDecoration(
                        labelText: _esModoRegistro
                            ? 'Crea una Contraseña'
                            : 'Contraseña',
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
                        if (_esModoRegistro && val.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirmar Contraseña (Solo Registro)
                    if (_esModoRegistro) ...[
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _ocultarPassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_clock),
                        ),
                        validator: (val) {
                          if (_esModoRegistro) {
                            if (val == null || val.isEmpty)
                              return 'Confirme su contraseña';
                            if (val != _passwordController.text)
                              return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    const SizedBox(height: 10),

                    // Botón de Acción
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
                        onPressed: _cargando ? null : _procesarFormulario,
                        child: _cargando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _esModoRegistro
                                    ? 'REGISTRARME E INGRESAR'
                                    : 'INGRESAR AL SISTEMA',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cambiar Modo
                    TextButton(
                      onPressed: _cargando
                          ? null
                          : () {
                              setState(() {
                                _esModoRegistro = !_esModoRegistro;
                                _formKey.currentState?.reset();
                              });
                            },
                      child: Text(
                        _esModoRegistro
                            ? '¿Ya tienes cuenta? Inicia Sesión aquí'
                            : '¿Eres nuevo profesional? Regístrate aquí',
                        style: TextStyle(
                          color: _colorRol,
                          fontWeight: FontWeight.bold,
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
