// lib/screens/triage_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos del Paciente
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _edadController = TextEditingController();

  // Signos Vitales
  final _paController = TextEditingController(); // Presión Arterial
  final _fcController = TextEditingController(); // Frecuencia Cardíaca
  final _frController = TextEditingController(); // Frecuencia Respiratoria
  final _tempController = TextEditingController(); // Temperatura
  final _spo2Controller = TextEditingController(); // Saturación de O2
  final _glucoController = TextEditingController(); // Glucemia

  // Procedimientos de Enfermería
  String _procedimiento = 'Control de Signos Vitales';
  final _notasController = TextEditingController();

  final List<String> _opcionesProcedimientos = [
    'Control de Signos Vitales',
    'Curación de Heridas / Postquirúrgico',
    'Administración de Medicamentos / Inyectología',
    'Canalización de Vía Periférica / Sueroterapia',
    'Toma de Muestras de Laboratorio',
    'Retiro de Puntos / Sondas',
  ];

  void _guardarAtencion() {
    if (_formKey.currentState!.validate()) {
      NotificationService.mostrarNotificacion(
        titulo: 'Registro de Enfermería Exitoso 🩺',
        mensaje: 'Atención guardada para ${_nombreController.text}.',
        icono: Icons.check_circle,
        colorFondo: Colors.indigo.shade800,
      );

      _formKey.currentState!.reset();
      _nombreController.clear();
      _cedulaController.clear();
      _edadController.clear();
      _paController.clear();
      _fcController.clear();
      _frController.clear();
      _tempController.clear();
      _spo2Controller.clear();
      _glucoController.clear();
      _notasController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Enfermería & Triaje'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección Datos del Paciente
              const Text(
                '1. DATOS DEL PACIENTE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombres y Apellidos Completos',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (v) => v!.length != 10 ? '10 dígitos' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _edadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad (Años)',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Sección Signos Vitales
              const Text(
                '2. SIGNOS VITALES Y SOMATOMETRÍA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _paController,
                      decoration: const InputDecoration(
                        labelText: 'P. Arterial (mmHg)',
                        hintText: '120/80',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fcController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'F. Cardíaca (bpm)',
                        hintText: '75',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        hintText: '36.5',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _spo2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'SpO2 (%)',
                        hintText: '98',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _glucoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Glucemia (mg/dL)',
                        hintText: '95',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Sección Procedimiento y Notas
              const Text(
                '3. ATENCIÓN Y NOTAS DE ENFERMERÍA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _procedimiento,
                decoration: const InputDecoration(
                  labelText: 'Procedimiento Principal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: _opcionesProcedimientos
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _procedimiento = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notasController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones / Evolución de Enfermería',
                  hintText:
                      'Ej. Paciente refiere alivio de dolor. Vía periférica permeable sin signos de flebitis.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _guardarAtencion,
                  icon: const Icon(Icons.save),
                  label: const Text('REGISTRAR ATENCIÓN DE ENFERMERÍA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
