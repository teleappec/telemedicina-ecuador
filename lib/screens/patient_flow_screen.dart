// lib/screens/patient_flow_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class PatientFlowScreen extends StatefulWidget {
  const PatientFlowScreen({super.key});

  @override
  State<PatientFlowScreen> createState() => _PatientFlowScreenState();
}

class _PatientFlowScreenState extends State<PatientFlowScreen> {
  final _formKey = GlobalKey<FormState>();

  // Coordinación Institucional
  String _tipoInstitucion = 'Universidad';
  final _nombreInstitucionController = TextEditingController();
  final _codigoProyectoController = TextEditingController();
  final _liderBrigadaController = TextEditingController();
  final _ubicacionSectorController = TextEditingController();

  // Datos del Paciente atendido en Campo
  final _pacienteNombreController = TextEditingController();
  final _pacienteCedulaController = TextEditingController();
  String _grupoVulnerable = 'Ninguno';
  String _motivoBrigada = 'Medicina Preventiva / Desparasitación';
  bool _requiereDerivacion = false;

  final List<String> _tiposInstituciones = [
    'Universidad',
    'Instituto Técnico / Tecnológico',
    'GAD Municipal / Parroquial',
    'Ministerio de Salud Pública (MSP)',
    'ONG / Fundación',
  ];

  final List<String> _gruposVulnerables = [
    'Ninguno',
    'Embarazada',
    'Adulto Mayor',
    'Persona con Discapacidad',
    'Niño / Niña (0-5 años)',
  ];

  final List<String> _motivosAtencion = [
    'Medicina Preventiva / Desparasitación',
    'Vacunación Esquema Regular / COVID',
    'Tamizaje de Presión y Diabetes',
    'Valoración Odontológica Inicial',
    'Atención Médica General de Campo',
  ];

  void _guardarAtencionBrigada() {
    if (_formKey.currentState!.validate()) {
      NotificationService.mostrarNotificacion(
        titulo: 'Registro de Brigada Guardado ⛺',
        mensaje:
            'Atención de ${_pacienteNombreController.text} enviada desde ${_nombreInstitucionController.text}.',
        icono: Icons.verified,
        colorFondo: Colors.deepOrange.shade800,
      );

      _pacienteNombreController.clear();
      _pacienteCedulaController.clear();
      setState(() {
        _requiereDerivacion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinación de Brigadas Terrenales'),
        backgroundColor: Colors.deepOrange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección Convenio e Institución
              const Text(
                '1. DATOS DE INTERVENCIÓN E INSTITUCIÓN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tipoInstitucion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Entidad Coadyuvante',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: _tiposInstituciones
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoInstitucion = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreInstitucionController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Institución / GAD / Universidad',
                  hintText: 'Ej. Universidad Central / GAD Calderón',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Ingrese la institución' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codigoProyectoController,
                      decoration: const InputDecoration(
                        labelText: 'Código Convenio / Proyecto',
                        hintText: 'BRIG-2026-04',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _liderBrigadaController,
                      decoration: const InputDecoration(
                        labelText: 'Responsable / Docente',
                        hintText: 'Dr. Marco Silva',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ubicacionSectorController,
                decoration: const InputDecoration(
                  labelText: 'Comunidad / Sector de Despliegue',
                  hintText: 'Ej. Barrio San José, Parroquia El Chagualo',
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Ingrese la ubicación' : null,
              ),

              const SizedBox(height: 24),
              // Sección Atención del Paciente en Campo
              const Text(
                '2. REGISTRO DE PACIENTE EN CAMPO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pacienteNombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Paciente',
                  prefixIcon: Icon(Icons.person_pin),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pacienteCedulaController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula de Identidad',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (v) => v!.length != 10 ? '10 dígitos' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _grupoVulnerable,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad / Grupo',
                        border: OutlineInputBorder(),
                      ),
                      items: _gruposVulnerables
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _grupoVulnerable = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _motivoBrigada,
                decoration: const InputDecoration(
                  labelText: 'Acción / Intervención Realizada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.biotech),
                ),
                items: _motivosAtencion
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _motivoBrigada = v!),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text(
                  '¿Requiere derivación urgente a Centro de Salud / Teleconsulta?',
                ),
                subtitle: Text(
                  _requiereDerivacion
                      ? 'Sí, notificar a Red MSP'
                      : 'No, atención concluida en sitio',
                ),
                value: _requiereDerivacion,
                activeColor: Colors.deepOrange,
                onChanged: (val) => setState(() => _requiereDerivacion = val),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _guardarAtencionBrigada,
                  icon: const Icon(Icons.send),
                  label: const Text('REGISTRAR FICHA DE BRIGADA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
