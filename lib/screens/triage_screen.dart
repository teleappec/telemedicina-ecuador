import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class TriageScreen extends StatefulWidget {
  final String nombreMedico;
  const TriageScreen({super.key, required this.nombreMedico});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _presionController = TextEditingController();
  final _tempController = TextEditingController();
  final _oxigenoController = TextEditingController();

  List<Map<String, dynamic>> _pacientesGuardados = [];
  bool _estaCargando = false;

  @override
  void initState() {
    super.initState();
    _cargarPacientesLocales();
  }

  Future<void> _cargarPacientesLocales() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosString = prefs.getString('pacientes_offline');
    if (datosString != null) {
      setState(() {
        _pacientesGuardados = List<Map<String, dynamic>>.from(
          jsonDecode(datosString),
        );
      });
    }
  }

  // Evaluación automática de riesgo por semáforo
  Map<String, dynamic> _calcularGravedad(double temp, int oxigeno) {
    if (oxigeno <= 89 || temp >= 39.0) {
      return {'nivel': 'CRÍTICO', 'color': 'ROJO'};
    } else if ((oxigeno >= 90 && oxigeno <= 94) || temp >= 38.0) {
      return {'nivel': 'URGENTE', 'color': 'AMARILLO'};
    } else {
      return {'nivel': 'ESTABLE', 'color': 'VERDE'};
    }
  }

  Future<void> _guardarPacienteLocal() async {
    if (_formKey.currentState!.validate()) {
      final double temp = double.tryParse(_tempController.text) ?? 36.5;
      final int oxigeno = int.tryParse(_oxigenoController.text) ?? 98;

      final evaluacion = _calcularGravedad(temp, oxigeno);

      final nuevoPaciente = {
        'cedula': _cedulaController.text,
        'nombre': _nombreController.text,
        'presion': _presionController.text,
        'temp': _tempController.text,
        'oxigeno': _oxigenoController.text,
        'prioridad': evaluacion['nivel'],
        'colorRiesgo': evaluacion['color'],
        'fecha': DateTime.now().toString(),
        'atendidoPor': widget.nombreMedico,
      };

      final prefs = await SharedPreferences.getInstance();
      _pacientesGuardados.add(nuevoPaciente);
      await prefs.setString(
        'pacientes_offline',
        jsonEncode(_pacientesGuardados),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paciente ${_nombreController.text} registrado con prioridad ${evaluacion['nivel']}.',
            ),
            backgroundColor: evaluacion['color'] == 'ROJO'
                ? Colors.red
                : (evaluacion['color'] == 'AMARILLO'
                      ? Colors.orange
                      : Colors.teal),
          ),
        );
      }

      _cedulaController.clear();
      _nombreController.clear();
      _presionController.clear();
      _tempController.clear();
      _oxigenoController.clear();
      setState(() {});
    }
  }

  Future<void> _sincronizarConServidor() async {
    if (_pacientesGuardados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay registros locales para sincronizar.'),
        ),
      );
      return;
    }

    setState(() => _estaCargando = true);

    final respuesta = await ApiService.sincronizarPacientes(
      _pacientesGuardados,
    );

    setState(() => _estaCargando = false);

    if (mounted) {
      if (respuesta['exito']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pacientes_offline');
        setState(() => _pacientesGuardados.clear());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(respuesta['mensaje']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(respuesta['mensaje']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _verRegistrosOffline() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pacientes Guardados Offline (${_pacientesGuardados.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _pacientesGuardados.isEmpty
                  ? const Center(
                      child: Text('No hay registros guardados localmente.'),
                    )
                  : ListView.builder(
                      itemCount: _pacientesGuardados.length,
                      itemBuilder: (context, index) {
                        final p = _pacientesGuardados[index];
                        final color = p['colorRiesgo'] == 'ROJO'
                            ? Colors.red
                            : (p['colorRiesgo'] == 'AMARILLO'
                                  ? Colors.orange
                                  : Colors.green);

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text(
                                p['prioridad'] != null &&
                                        p['prioridad'].toString().isNotEmpty
                                    ? p['prioridad'][0]
                                    : 'E',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(p['nombre'] ?? 'Sin Nombre'),
                            subtitle: Text(
                              'Cédula: ${p['cedula']} | PA: ${p['presion']} | SpO2: ${p['oxigeno']}% | Prioridad: ${p['prioridad']}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_pacientesGuardados.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _estaCargando ? null : _sincronizarConServidor,
                  icon: const Icon(Icons.cloud_upload),
                  label: _estaCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SINCRONIZAR CON EL SERVIDOR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triaje - ${widget.nombreMedico}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_pacientesGuardados.length}'),
              child: const Icon(Icons.sd_storage),
            ),
            onPressed: _verRegistrosOffline,
            tooltip: 'Ver registros locales',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos del Paciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cédula de Identidad',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese la cédula' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Signos Vitales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _presionController,
                      decoration: const InputDecoration(
                        labelText: 'Presión (120/80)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _oxigenoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saturación Oxígeno (%)',
                  prefixIcon: Icon(Icons.speed),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarPacienteLocal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'GUARDAR PACIENTE (OFFLINE)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
