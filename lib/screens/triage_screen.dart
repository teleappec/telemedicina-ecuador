import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  List<dynamic> _atenciones = [];
  bool _cargando = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pacienteController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _paController = TextEditingController(
    text: '120/80',
  );
  final TextEditingController _fcController = TextEditingController(text: '75');
  final TextEditingController _tempController = TextEditingController(
    text: '36.5',
  );
  final TextEditingController _spo2Controller = TextEditingController(
    text: '98',
  );
  final TextEditingController _obsController = TextEditingController();

  String _clasificacionSeleccionada = 'Verde (Sin Riesgo Vital)';
  final List<String> _clasificaciones = [
    'Rojo (Reanimación - Emergencia)',
    'Amarillo (Urgencia)',
    'Verde (Sin Riesgo Vital)',
    'Azul (Consulta No Urgente)',
  ];

  @override
  void initState() {
    super.initState();
    _cargarTriajes();
  }

  Future<void> _cargarTriajes() async {
    setState(() => _cargando = true);
    final lista = await ApiService.obtenerAtenciones();
    if (!mounted) return;
    setState(() {
      _atenciones = lista;
      _cargando = false;
    });
  }

  Color _obtenerColorPrioridad(String clasificacion) {
    if (clasificacion.contains('Rojo')) {
      return Colors.red;
    }
    if (clasificacion.contains('Amarillo')) {
      return Colors.amber.shade700;
    }
    if (clasificacion.contains('Verde')) {
      return Colors.green;
    }
    return Colors.blue;
  }

  Future<void> _mostrarModalNuevoTriaje() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nueva Ficha de Triaje (Enfermería)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pacienteController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Paciente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cédula Paciente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _clasificacionSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Clasificación de Prioridad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.traffic),
                    ),
                    items: _clasificaciones
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _clasificacionSeleccionada = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paController,
                          decoration: const InputDecoration(
                            labelText: 'P.A. (mmHg)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _fcController,
                          decoration: const InputDecoration(
                            labelText: 'F.C. (bpm)',
                            border: OutlineInputBorder(),
                          ),
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
                          decoration: const InputDecoration(
                            labelText: 'Temp (°C)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _spo2Controller,
                          decoration: const InputDecoration(
                            labelText: 'SpO2 (%)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _obsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Síntomas / Observaciones',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.pop(context);

                        final res = await ApiService.registrarTriaje({
                          'paciente': _pacienteController.text.trim(),
                          'cedula_paciente': _cedulaController.text.trim(),
                          'presion_arterial': _paController.text.trim(),
                          'frecuencia_cardiaca':
                              '${_fcController.text.trim()} bpm',
                          'temperatura': '${_tempController.text.trim()} °C',
                          'saturacion_oxigeno':
                              '${_spo2Controller.text.trim()}%',
                          'clasificacion': _clasificacionSeleccionada,
                          'observaciones': _obsController.text.trim(),
                        });

                        if (res['exito'] == true) {
                          NotificationService.mostrarNotificacion(
                            titulo: 'Triaje Guardado 🩺',
                            mensaje:
                                'Ficha de enfermería sincronizada con Render.',
                            icono: Icons.health_and_safety,
                            colorFondo: const Color(0xFF26A69A),
                          );
                          _pacienteController.clear();
                          _cedulaController.clear();
                          _obsController.clear();
                          _cargarTriajes();
                        }
                      },
                      child: const Text('GUARDAR FICHA DE TRIAJE'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triaje y Signos Vitales'),
        backgroundColor: const Color(0xFF26A69A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTriajes,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _atenciones.isEmpty
          ? const Center(child: Text('No hay fichas de triaje registradas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _atenciones.length,
              itemBuilder: (context, index) {
                final item = _atenciones[index];
                final String clasif = item['clasificacion'] ?? 'Verde';
                final colorPrioridad = _obtenerColorPrioridad(clasif);

                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorPrioridad,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['paciente'] ?? 'Sin Nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item['clasificacion']}\nPA: ${item['presion_arterial']} | FC: ${item['frecuencia_cardiaca']} | Temp: ${item['temperatura']} | SpO2: ${item['saturacion_oxigeno']}\nObs: ${item['observaciones'] ?? "Ninguna"}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      item['fecha'] ?? '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalNuevoTriaje,
        backgroundColor: const Color(0xFF26A69A),
        icon: const Icon(Icons.medical_services),
        label: const Text('Nuevo Triaje'),
      ),
    );
  }
}
