import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<dynamic> _citas = [];
  bool _cargando = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pacienteController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  String _especialidadSeleccionada = 'Medicina General';
  final List<String> _especialidades = [
    'Medicina General',
    'Pediatría',
    'Ginecología',
    'Cardiología',
    'Odontología',
  ];

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() => _cargando = true);
    final citas = await ApiService.obtenerCitas();
    if (!mounted) return;
    setState(() {
      _citas = citas;
      _cargando = false;
    });
  }

  Future<void> _mostrarModalAgendar() async {
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
                    'Agendar Nueva Cita Médica',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pacienteController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Paciente',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cédula Paciente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _especialidadSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      border: OutlineInputBorder(),
                    ),
                    items: _especialidades
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null)
                        setState(() => _especialidadSeleccionada = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fechaController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha (AAAA-MM-DD)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _horaController,
                          decoration: const InputDecoration(
                            labelText: 'Hora (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _motivoController,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de Consulta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.pop(context);

                        final res = await ApiService.agendarCita({
                          'paciente': _pacienteController.text.trim(),
                          'cedula_paciente': _cedulaController.text.trim(),
                          'especialidad': _especialidadSeleccionada,
                          'fecha': _fechaController.text.trim(),
                          'hora': _horaController.text.trim(),
                          'motivo': _motivoController.text.trim(),
                        });

                        if (res['exito'] == true) {
                          NotificationService.mostrarNotificacion(
                            titulo: 'Cita Agendada 📅',
                            mensaje:
                                'La cita ha sido registrada en el servidor.',
                            icono: Icons.calendar_today,
                            colorFondo: Colors.teal,
                          );
                          _pacienteController.clear();
                          _cedulaController.clear();
                          _fechaController.clear();
                          _horaController.clear();
                          _motivoController.clear();
                          _cargarCitas();
                        }
                      },
                      child: const Text('GUARDAR CITA'),
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
        title: const Text('Gestión de Citas Médicas'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarCitas),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _citas.isEmpty
          ? const Center(child: Text('No hay citas programadas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _citas.length,
              itemBuilder: (context, index) {
                final cita = _citas[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      cita['paciente'] ?? 'Sin Nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${cita['especialidad']} - ${cita['fecha']} | ${cita['hora']}\nMotivo: ${cita['motivo'] ?? "N/A"}',
                    ),
                    trailing: Chip(
                      label: Text(cita['estado'] ?? 'Pendiente'),
                      backgroundColor: Colors.teal.shade50,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalAgendar,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }
}
