import 'package:flutter/material.dart';
import '../api_service.dart';
import 'triage_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _senescytController = TextEditingController();
  bool _cargando = false;

  void _validarEIngresar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      final respuesta = await ApiService.validarMedico(
        _cedulaController.text.trim(),
        _senescytController.text.trim(),
      );

      setState(() => _cargando = false);

      if (!mounted) return;

      if (respuesta['exito']) {
        final medico = respuesta['medico'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bienvenido/a ${medico['nombre']} (${medico['especialidad']})',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TriageScreen(nombreMedico: medico['nombre']),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Acceso Denegado'),
              ],
            ),
            content: Text(respuesta['mensaje']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'TeleMedicina Ecuador',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const Text(
                      'Validación de Personal Médico',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cédula de Identidad',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingrese la cédula' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senescytController,
                      decoration: const InputDecoration(
                        labelText: 'Nº Registro SENESCYT',
                        prefixIcon: Icon(Icons.verified),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 1005-2022-8844',
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Ingrese el número SENESCYT'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _validarEIngresar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'VALIDAR E INGRESAR',
                                style: TextStyle(fontSize: 16),
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
